//
//  BTPeripheralConnectedCondition.swift
//  BLE-Central-OSX
//
//  Created by d503 on 5/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import Operations

class BTPeripheralConnectedCondition: BTBaseCondition {
    
    // MARK: Private Properties
    
    private unowned var peripheral: BTPeripheralAPIType
    
    // MARK: Initializers
    
    init(peripheral: BTPeripheralAPIType) {
        self.peripheral = peripheral
        super.init(mutuallyExclusive: false)
    }
    
    override func evaluate(operation: Operation, completion: OperationConditionResult -> Void) {
        if peripheral.state == .Connected {
            completion(.Satisfied)
        }
        else {
            let error = BTPeripheralStateInvalidError(withExpectedState: .Connected,
                                                      realState: peripheral.state)
            completion(.Failed(error))
        }
    }
}