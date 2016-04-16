//
//  BTBaseStubPeripheral.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/7/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
@testable import BLE_Central_OSX

@objc class BTBaseStubPeripheral: NSObject, BTPeripheralAPIType {
        
    private(set) var identifier: NSUUID = NSUUID()
    
    private(set) var name: String?
    
    private(set) var state: CBPeripheralState = .Disconnected
    
    private(set) var services: [CBService]?
    
    // MARK: Private Properties
    
    private(set) var handlerContainer = BTHandlersContainer<BTPeripheralHandlerProtocol>()
    
    // MARK: Discover services and characterictics
    
    func discoverServices(serviceUUIDs: [CBUUID]?) {
        
    }
    
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, forService service: CBService) {
        
    }
    
    // MARK: write value for characteristic
    
    func writeValue(data: NSData, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        
    }
    
    // MARK: subscribe on value update notifications for characteristic
    
    func setNotifyValue(enabled: Bool, forCharacteristic characteristic: CBCharacteristic) {
        
    }
    
    func coreBluetoothPeripheral() -> CBPeripheral {
        return BTStubCBPeriheral(name: "")
    }

    // MARK: Add handler
    
    func addHandler(handlerToAdd: BTPeripheralHandlerProtocol) {
        handlerContainer.addHandler(handlerToAdd)
    }
    
    func removeHandler(handlerToRemove: BTPeripheralHandlerProtocol) {
        handlerContainer.removeHandler(handlerToRemove)
    }
}

private class BTStubCBPeriheral: CBPeripheral {
    init(name: String) {}
}
