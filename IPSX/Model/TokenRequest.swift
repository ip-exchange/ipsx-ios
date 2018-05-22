//
//  TokenRequest.swift
//  IPSX
//
//  Created by Cristina Virlan on 10/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

struct TokenRequest {
    
    var ethID: String
    var amount: String
    var status: String
    var created: Date?
    
    init(ethID: String = "", amount: String = "", status: String = "",created: Date? = nil) {
        
        self.ethID = ethID
        self.amount = amount
        self.status = status
        self.created = created
    }
    
    func isFromToday() -> Bool {
        
        //TODO(CC): implement this
        return false
    }
}
