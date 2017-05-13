//
//  BTStartAdvertisingOperation.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations

class BTStartAdvertisingOperation: BTPeripheralManagerOperation {
    
    // MARK: Internal Properties
    
    var advertisingData: [String : AnyObject]?
    
    // MARK: Initializers
    
    init(peripheralManager: BTPeripheralManagerAPIType,
         peripheralRolePerformer: BTPeripheralRolePerformer,
         mutuallyExclusiveCondition: Condition =
        MutuallyExclusive<BTPeripheralManagerProxy>()) {
        
        super.init(withPeripheralManager: peripheralManager)
        
        addCondition(mutuallyExclusiveCondition)
        addCondition(BTPeripheralManagerPoweredOnCondition(withPeripheralManager: peripheralManager))
        addCondition(NegatedCondition(
            BTServiceNotAddedCondition(withPeripheralRolePerformer: peripheralRolePerformer)))
        addCondition(BTPeripheralNotAdvertisingCondition(withPeripheralManager: peripheralManager))
    }
    
    private override init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType) {
        super.init(withPeripheralManager: peripheralManager)
        fatalError()
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        peripheralManager?.addHandler(self)
        
        peripheralManager?.startAdvertising(advertisingData)
    }
}

extension BTStartAdvertisingOperation: BTPeripheralManagerHandlerProtocol {
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        // nothing to do here
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: BTPeripheralManagerAPIType, error: NSError?) {
        removeHandlerAndFinish(error)
    }
}
