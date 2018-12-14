//
//  Refund.swift
//  IPSX
//
//  Created by Calin Chitu on 12/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation
import IPSXNetworkingFramework

struct Refund {
    
    var id: Int
    var value: String
    var status: String //pending, completed, rejected
    var createdAt: Date?
    var issuedByUser: Bool
    var userReason: String
    var adminReason: String
    var proxyId: Int
    
    init(json: JSON) {
        
        let dateFormatter = DateFormatter.backendResponseParse()
        
        self.id = json["id"].intValue
        self.value = json["value"].doubleValue.cleanString
        self.status = json["status"].stringValue
        let createdAtString = json["created_at"].stringValue
        self.createdAt = dateFormatter.date(from: createdAtString)
        self.userReason = json["reason"].stringValue
        self.adminReason = json["admin_reason"].stringValue
        self.issuedByUser = json["by_user_id"].stringValue == UserManager.shared.userId
        self.proxyId = json["order_offer_proxy_id"].intValue
    }
}
