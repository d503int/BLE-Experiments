//
//  BTPeripheralScanSignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/29/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReactiveCocoa
import Operations

class BTPeripheralScanSignalProvider {
    
    // MARK: Private Properties

    private let centralManager: BTCentralManagerAPIType
    private let serviceUUIDs: [CBUUID]?
    private let options: [String : AnyObject]?
    private let allowDuplicatePeripheralIds: Bool
    private let cleanNotUsedPeripherals: Bool
    private let timeout: NSTimeInterval
    private let validatePeripheralPredicate: BTCentralManagerScanningOperation.BTScanningValidPeripheralPredicate?
    private let stopScanningCondition: BTCentralManagerScanningOperation.BTScanningStopBlock
    
    private let centralRolePerformer: BTCentralRolePerforming
    
    private var scanOperation: BTCentralManagerScanningOperation? = nil
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         serviceUUIDs: [CBUUID]? = nil,
         options: [String : AnyObject]? = nil,
         allowDuplicatePeripheralIds: Bool = false,
         cleanNotUsedPeripherals: Bool = true,
         timeout: NSTimeInterval = 10,
         validatePeripheralPredicate: BTCentralManagerScanningOperation.BTScanningValidPeripheralPredicate? = nil,
         stopScanningCondition: BTCentralManagerScanningOperation.BTScanningStopBlock,
         centralRolePerformer: BTCentralRolePerforming) {
        
        self.centralManager = centralManager
        self.serviceUUIDs = serviceUUIDs
        self.options = options
        self.allowDuplicatePeripheralIds = allowDuplicatePeripheralIds
        self.cleanNotUsedPeripherals = cleanNotUsedPeripherals
        self.timeout = timeout
        self.validatePeripheralPredicate = validatePeripheralPredicate
        self.stopScanningCondition = stopScanningCondition
        self.centralRolePerformer = centralRolePerformer
    }
    
    // MARK: Internal Methods
    
    func scan() -> SignalProducer<[BTPeripheral], BTError> {
        
        return SignalProducer { observer, disposable in
            let startScanningOperation = BTCentralManagerScanningOperation(
                centralManager: self.centralManager,
                serviceUUIDs: self.serviceUUIDs,
                options: self.options,
                allowDuplicatePeripheralIds: self.allowDuplicatePeripheralIds,
                timeout: self.timeout,
                validatePeripheralPredicate: self.validatePeripheralPredicate,
                intermediateScanResultBlock: {
                    [weak self] (discoveryResults: [BTPeripheralScanResult]) in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    for discoveryResult in discoveryResults {
                        strongSelf.centralRolePerformer.updateManagedPeripheral(discoveryResult.peripheral)
                    }
                    
                    let modelPeripherals = discoveryResults.map {
                        BTPeripheral.createWithScanResult($0)
                    }
                    
                    for modelPeripheral in modelPeripherals {
                        strongSelf.centralRolePerformer.updateModelPeripheral(modelPeripheral)
                    }
                    
                    observer.sendNext(modelPeripherals)
                },
                stopScanningCondition: self.stopScanningCondition)
            
            startScanningOperation.addObserver(WillExecuteObserver { [weak self] operation in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.centralRolePerformer.setScanningForPeripheralsInProgress(true)
                
                if strongSelf.cleanNotUsedPeripherals {
                    strongSelf.centralRolePerformer.removeNotUsedModelPeripherals()
                }
                })
            
            startScanningOperation.addObserver(DidFinishObserver { [weak self] (operation, errors) in
                
                guard let strongSelf = self else {
                    return
                }
                
                if operation.finished && errors.count > 0 {
                    
                    let timeoutErrorIndex = errors.indexOf({
                        if let timeoutError = $0 as? OperationError {
                            if case .OperationTimedOut(_) = timeoutError {
                                return true
                            }
                        }
                        return false
                    })
                    
                    if timeoutErrorIndex == nil {
                        let error = BTOperationError(code: .OperationFailed(errors: errors))
                        Log.bluetooth.error("BTPeripheralScanSignalProvider: scanning, error: \(error)")
                        strongSelf.centralRolePerformer.setScanningForPeripheralsInProgress(false)
                        observer.sendFailed(error)
                        return
                    }
                }
                
                guard let scanningOperation = operation as? BTCentralManagerScanningOperation else {
                    let error = BTOperationError(code: .OperationTypeMismatch)
                    Log.bluetooth.error("BTPeripheralScanSignalProvider: scanning, error: \(error)")
                    strongSelf.centralRolePerformer.setScanningForPeripheralsInProgress(false)
                    observer.sendFailed(error)
                    return
                }
                
                Log.bluetooth.info("BTPeripheralScanSignalProvider: scan completed, discovered \(scanningOperation.discoveryResults.count) peripherals")
                Log.bluetooth.verbose("BTPeripheralScanSignalProvider: discovery results: \(scanningOperation.discoveryResults.count)")
                
                for discoveryResult in scanningOperation.discoveryResults {
                    strongSelf.centralRolePerformer.updateManagedPeripheral(discoveryResult.peripheral)
                }
                
                let modelPeripherals = scanningOperation.discoveryResults.map {
                    BTPeripheral.createWithScanResult($0)
                }
                
                //FIXME: temp fix
                
//                for modelPeripheral in modelPeripherals {
//                    strongSelf.centralRolePerformer.updateModelPeripheral(modelPeripheral)
//                }
                
                strongSelf.centralRolePerformer.setScanningForPeripheralsInProgress(false)
                observer.sendNext(modelPeripherals)
                observer.sendCompleted()
                })
            
            self.scanOperation = startScanningOperation
            
            self.centralRolePerformer.operationQueue.addOperation(startScanningOperation)
            
            disposable.addDisposable {
                self.scanOperation = nil
            }
        }
    }
    
    func stopScan() {
        if let op = scanOperation where !op.finished {
            op.cancel()
            scanOperation = nil
        }
    }
}
