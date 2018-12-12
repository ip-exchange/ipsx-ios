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
    var amount: String
    var status: String //pending, complete, canceled, expired
    var createdAt: Date?
    var updatedAt: Date?

    init(json: JSON) {
        
        let dateFormatter = DateFormatter.backendResponseParse()
        
        self.depositID        = json["id"].intValue
        self.ethID            = json["usereth_id"].intValue
        self.amount           = json["value"].doubleValue.cleanString
        self.status           = json["status"].stringValue
        let createdAtString   = json["created_at"].stringValue
        self.createdAt        = dateFormatter.date(from: createdAtString)
        let updatedAtString   = json["updated_at"].stringValue
        self.updatedAt        = dateFormatter.date(from: updatedAtString)
   }
}
