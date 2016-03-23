//
//  BTPeripheralRolePerformer.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/21/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import CocoaLumberjack
import Operations

private let UUID: String = "336453FB-183F-4277-923C-7C1F45CD13F8"


class BTPeripheralRolePerformer: NSObject {
    
    // MARK: Private Properties

    private var peripheralManager: BTPeripheralManagerProxy

    private(set) var services: [BTService] = []
    private(set) var servicesAdded: Bool = false
    
    // MARK: Operations
    
    private var operationQueue: OperationQueue
    
    // MARK: Initializers
    
    init(services: [BTService]) {
        
        operationQueue = OperationQueue()
        
        let periphralManager = CBPeripheralManager(delegate: nil,
            queue: nil,
            options: [CBPeripheralManagerOptionShowPowerAlertKey : true])
        
        peripheralManager = BTPeripheralManagerProxy(peripheralManager: periphralManager)
        
        self.services = services
        
        super.init()
        
        peripheralManager.addHandler(self)
    }
    
    convenience override init() {
        
        let characteristics = [
            BTCharacteristic(UUIDString: "2A4D",
                propeties: [.WriteWithoutResponse, .Write],
                initialValue: nil,
                permissions: .Writeable),
            BTCharacteristic(UUIDString: "2A4D",
                propeties: .Notify,
                initialValue: nil,
                permissions: .Readable)
        ]
        
        let mainService = BTService(UUIDString: "C14D2C0A-401F-B7A9-841F-E2E93B80F631",
            primary: false,
            characteristics: characteristics)
    
        self.init(services: [mainService])
    }
    
    // MARK: Internal Methods

    
    func startAdevertising() {
        
        
    }
}

// MARK: BTPeripheralManagerHandlerProtocol

extension BTPeripheralRolePerformer: BTPeripheralManagerHandlerProtocol {
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        DDLogVerbose("PeripheralManager: did update state = \(peripheral.state)")
        
        addServices()
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didAddService service: CBService, error: NSError?) {
        DDLogVerbose("PeripheralManager: did add service \(service) with error = \(error)")
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: BTPeripheralManagerAPIType, error: NSError?) {
        DDLogVerbose("PeripheralManager: did start advertising with error = \(error)")
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didReceiveReadRequest request: CBATTRequest) {
        DDLogVerbose("PeripheralManager: did receive read request = \(request)")
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didReceiveWriteRequests requests: [CBATTRequest]) {
        DDLogVerbose("PeripheralManager: did receive write requests = \(requests)")
    }
}

// MARK: Private methods

private extension BTPeripheralRolePerformer {
    func addServices() {
        let addServiceOperation = BTAddServicesOperation(withPeripheralManager: peripheralManager,
            peripheralRolePerformer: self,
            services: services)
        
        addServiceOperation.addObserver(DidFinishObserver { [weak weakSelf = self] result in
            
            if result.operation.finished && result.errors.isEmpty {
                weakSelf?.servicesAdded = true
            }
            else {
                weakSelf?.servicesAdded = false
            }
            
            })
        
        operationQueue.addOperation(addServiceOperation)
    }
}
