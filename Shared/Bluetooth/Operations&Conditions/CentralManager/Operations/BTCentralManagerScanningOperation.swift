//
//  BTCentralManagerScanningOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

typealias BTPeripheralScanResult = (
    peripheral: BTPeripheralAPIType,
    advertisementData: [String : AnyObject],
    RSSI: NSNumber)

class BTCentralManagerScanningOperation: BTCentralManagerOperation {
    
    typealias BTScanningResultBlock = (discoveryResults: [BTPeripheralScanResult]) -> Void
    typealias BTScanningStopBlock = (discoveryResults: [BTPeripheralScanResult]) -> Bool
    typealias BTScanningValidPeripheralPredicate = (discoveryResult: BTPeripheralScanResult) -> Bool

    // MARK: Private Properties
    
    private let serviceUUIDs: [CBUUID]?
    private let options: [String : AnyObject]?
    private let allowDuplicatePeripheralIds: Bool
    private let validatePeripheralPredicate: BTScanningValidPeripheralPredicate?
    private let intermediateScanResultBlock: BTScanningResultBlock?
    private let stopScanningCondition: BTScanningStopBlock
    
    private(set) var discoveryResults: [BTPeripheralScanResult] = []
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         serviceUUIDs: [CBUUID]? = nil,
         options: [String : AnyObject]? = nil,
         allowDuplicatePeripheralIds: Bool = false,
         timeout: NSTimeInterval = 10,
         validatePeripheralPredicate: BTScanningValidPeripheralPredicate? = nil,
         intermediateScanResultBlock: BTScanningResultBlock? = nil,
         stopScanningCondition: BTScanningStopBlock,
         mutuallyExclusiveCondition: Condition = MutuallyExclusive<BTCentralManagerScanningOperation>()) {
        self.serviceUUIDs = serviceUUIDs
        self.options = options
        self.allowDuplicatePeripheralIds = allowDuplicatePeripheralIds
        self.validatePeripheralPredicate = validatePeripheralPredicate
        self.intermediateScanResultBlock = intermediateScanResultBlock
        self.stopScanningCondition = stopScanningCondition
        
        super.init(centralManager: centralManager)
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
        addCondition(mutuallyExclusiveCondition)
        
        addObserver(TimeoutObserver(timeout: timeout))
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        
        centralManager?.scanForPeripheralsWithServices(serviceUUIDs,
                                                       options: options)
    }
    
    override func operationWillCancel(errors: [ErrorType]) {
        centralManager?.stopScan()
        centralManager?.removeHandler(self)
        super.operationWillCancel(errors)
    }
}

extension BTCentralManagerScanningOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        if central.state != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                          realState: central.state)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        didDiscoverPeripheral peripheral: BTPeripheralAPIType,
                                              advertisementData: [String : AnyObject],
                                              RSSI: NSNumber) {
        
        if !allowDuplicatePeripheralIds {
            if let _ = discoveryResults.indexOf({
                return $0.peripheral.identifier.isEqual(peripheral.identifier) }) {
                return
            }
        }
        
        let discoveryResult = BTPeripheralScanResult(
            peripheral: peripheral,
            advertisementData: advertisementData,
            RSSI: RSSI)
        
        if let predicate = validatePeripheralPredicate {
            if predicate(discoveryResult: discoveryResult) {
                newPeripheralDiscovered(discoveryResult)
            }
        }
        else {
            newPeripheralDiscovered(discoveryResult)
        }
    }
}

// MARK: Supporting Methdods

private extension BTCentralManagerScanningOperation {
    func newPeripheralDiscovered(discoveryResult: BTPeripheralScanResult) {
        
        discoveryResults.append(discoveryResult)
        intermediateScanResultBlock?(discoveryResults: discoveryResults)
        
        if stopScanningCondition(discoveryResults: discoveryResults) {
            centralManager?.stopScan()
            removeHandlerAndFinish()
        }
    }
}
