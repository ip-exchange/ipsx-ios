//
//  Deposit.swift
//  IPSX
//
//  Created by Cristina Virlan on 08/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation
import IPSXNetworkingFramework

struct Deposit {
    
    var depositID: Int
    var ethID: Int
    var amountRequested: String
    var amountReceived: String
    var status: String //pending, complete, canceled, expired
    var watchUntil: Date?
    var createdAt: Date?

    init(json: JSON) {
        
        let dateFormatter = DateFormatter.backendResponseParse()
        
        self.depositID        = json["id"].intValue
        self.ethID            = json["usereth_id"].intValue
        self.amountRequested  = json["amount_requested"].doubleValue.cleanString
        self.amountReceived   = json["amount_received"].doubleValue.cleanString
        self.status           = json["status"].stringValue
        let watchUntilString  = json["watch_until"].stringValue
        self.watchUntil       = dateFormatter.date(from: watchUntilString)
        let createdAtString   = json["created_at"].stringValue
        self.createdAt        = dateFormatter.date(from: createdAtString)

    }
}
