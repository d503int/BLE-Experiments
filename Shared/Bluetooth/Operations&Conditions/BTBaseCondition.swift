//
//  BTBaseCondition.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations

class BTBaseCondition: Condition {
    
    // MARK: Initializers

    init(mutuallyExclusive: Bool) {
        super.init()
        self.mutuallyExclusive = mutuallyExclusive
        self.name = NSStringFromClass(self.dynamicType)
    }
}