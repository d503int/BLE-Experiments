//
//  BTAddServicesOperation.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations
import CoreBluetooth

class BTAddServicesOperation: BTPeripheralManagerOperation {
    
    // MARK: Properties
    
    private var services: [BTPrimacyService]
    
    // MARK: Initializers
    
    init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType,
                               peripheralRolePerformer: BTPeripheralRolePerformer,
                               services: [BTPrimacyService],
                               mutuallyExclusiveCondition: Condition =
        MutuallyExclusive<BTPeripheralManagerProxy>()) {
        self.services = services
        super.init(withPeripheralManager: peripheralManager)
        
        addCondition(mutuallyExclusiveCondition)
        addCondition(BTServiceNotAddedCondition(withPeripheralRolePerformer: peripheralRolePerformer))
    }
    
    private override init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType) {
        services = []
        super.init(withPeripheralManager: peripheralManager)
        fatalError()
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        peripheralManager?.addHandler(self)
        
        services.map { $0.coreBluetoothMUtableService() }.forEach { (service: CBMutableService) -> () in
            peripheralManager?.addService(service)
        }
    }
}

extension BTAddServicesOperation: BTPeripheralManagerHandlerProtocol {
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        if peripheral.state != .Resetting || peripheral.state != .PoweredOn {
            let error = BTPeripheralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                             realState: peripheral.state)
            removeHandlerAndFinish(error)
        }
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didAddService service: CBService, error: NSError?) {
        removeHandlerAndFinish(error)
    }
}
