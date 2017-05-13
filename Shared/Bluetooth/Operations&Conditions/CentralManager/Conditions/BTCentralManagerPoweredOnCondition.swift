//
//  BTCentralManagerPoweredOnCondition.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import Operations

class BTCentralManagerPoweredOnCondition: BTBaseCondition {
    
    // MARK: Private Properties
    
    private unowned var centralManager: BTCentralManagerAPIType
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType) {
        self.centralManager = centralManager
        super.init(mutuallyExclusive: false)
    }
        
    override func evaluate(operation: Operation, completion: OperationConditionResult -> Void) {
        if centralManager.state == .PoweredOn {
            completion(.Satisfied)
        }
        else {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                      realState: centralManager.state)
            completion(.Failed(error))
        }
    }
}

class BTCentralManagerPoweredOnWaitingCondition: BTCentralManagerPoweredOnCondition {
    
    override init(centralManager: BTCentralManagerAPIType) {
        super.init(centralManager: centralManager)
        addDependency(BTCentralManagerPoweredOnWaitingOperation(centralManager: centralManager))
    }
}

class BTCentralManagerPoweredOnWaitingOperation: BTCentralManagerOperation {
    
    override func execute() {
        guard !cancelled else { return }
        
        guard centralManager?.state != .PoweredOn else {
            finish()
            return
        }
        
        centralManager?.addHandler(self)
    }
}

extension BTCentralManagerPoweredOnWaitingOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        if central.state == .PoweredOn {
            centralManager?.removeHandler(self)
            finish()
        }
    }
}