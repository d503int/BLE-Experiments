//
//  BTPeripheralSetNotifyValueOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 5/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

class BTPeripheralSetNotifyValueOperation: BTPeripheralOperation {
    
    private(set) var updatedCharacteristic: CBCharacteristic? = nil
    
    // MARK: Private Properties
    
    private let notificationEnabled: Bool
    private let characterictic: CBCharacteristic
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         characterictic: CBCharacteristic,
         notificationEnabled: Bool,
         mutuallyExclusiveCondition: Condition = MutuallyExclusive<BTPeripheralSetNotifyValueOperation>()) {
        
        self.notificationEnabled = notificationEnabled
        self.characterictic = characterictic
        
        super.init(centralManager: centralManager,
                   peripheral: peripheral)
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
        addCondition(BTPeripheralConnectedCondition(peripheral: peripheral))
        addCondition(mutuallyExclusiveCondition)
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        peripheral?.addHandler(self)
        
        peripheral?.setNotifyValue(notificationEnabled,
                                   forCharacteristic: characterictic)
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTPeripheralSetNotifyValueOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        
        if central.state != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                          realState: central.state)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(
        central: BTCentralManagerAPIType,
        didDisconnectPeripheral peripheral: BTPeripheralAPIType,
                                error: NSError?) {
        
        let btError: ErrorType? = (error != nil) ?
                BTCentralManagerDidDisconnectPeripheralError(originalError: error) : nil
        removeHandlerAndFinish(btError)
    }
}

// MARK: BTPeripheralHandlerProtocol

extension BTPeripheralSetNotifyValueOperation: BTPeripheralHandlerProtocol {
    
    func peripheral(
        peripheral: BTPeripheralAPIType,
        didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic,
                                                    error: NSError?) {
        
        if let originalError = error {
            let btError = BTPeripheralUpdateNotificationStateForCharacteristicError(
                characteristicUUID: (characteristic.UUID.copy() as! CBUUID),
                originalError: originalError)
            removeHandlerAndFinish(btError)
            return
        }
        
        updatedCharacteristic = characteristic
        
        removeHandlerAndFinish()
    }
}
