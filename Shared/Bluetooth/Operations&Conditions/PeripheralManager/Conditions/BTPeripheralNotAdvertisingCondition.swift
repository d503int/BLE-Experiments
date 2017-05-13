//
//  BTPeripheralNotAdvertisingCondition.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/25/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations

struct BTPeripheralAlreadyAdvertisingError: ErrorType { }

class BTPeripheralNotAdvertisingCondition: BTBaseCondition {
    
    // MARK: Private Properties
    
    private unowned var peripheralManager: BTPeripheralManagerAPIType
    
    // MARK: Initializers
    
    init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType) {
        self.peripheralManager = peripheralManager
        super.init(mutuallyExclusive: false)
    }
    
    override func evaluate(operation: Operation, completion: OperationConditionResult -> Void) {
        if peripheralManager.isAdvertising {
            completion(.Failed(BTPeripheralAlreadyAdvertisingError()))
        }
        else {
            completion(.Satisfied)
        }
    }
}
