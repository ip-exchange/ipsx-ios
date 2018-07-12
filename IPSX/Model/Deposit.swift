//
//  Deposit.swift
//  IPSX
//
//  Created by Cristina Virlan on 08/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

struct Deposit {
    
    var depositID: Int
    var ethID: Int
    var amount: String
    var status: String
    var watchUntil: Date?
    var createdAt: Date?

    init(depositID: Int = 0, ethID: Int = 0, amount: String = "", status: String = "",watchUntil: Date? = nil, createdAt: Date? = nil) {
        
        self.depositID  = depositID
        self.ethID      = ethID
        self.amount     = amount
        self.status     = status
        self.watchUntil = watchUntil
        self.createdAt  = createdAt
    }
}
