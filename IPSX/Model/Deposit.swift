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
    var amountRequested: String
    var amountReceived: String
    var status: String //pending, complete, canceled, expired
    var watchUntil: Date?
    var createdAt: Date?

    init(depositID: Int = 0, ethID: Int = 0, amountRequested: String = "", amountReceived: String = "", status: String = "",watchUntil: Date? = nil, createdAt: Date? = nil) {
        
        self.depositID  = depositID
        self.ethID      = ethID
        self.status     = status
        self.watchUntil = watchUntil
        self.createdAt  = createdAt
        self.amountRequested = amountRequested
        self.amountReceived  = amountReceived
    }
}
