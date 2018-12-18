//
//  Order.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class Order {
    
    var id: Int
    var created: Date
    var status: String
    var offers: [Offer] = []
    var summary: Summary?
    
    init(id: Int, created: Date, status: String) {
        
        self.id  = id
        self.created = created
        self.status = status
    }
    
    func setOffers(offers: [Offer]) {
        self.offers = offers
    }
    
    func setSummary(summary: Summary) {
        self.summary = summary
    }
    
    func addProxyDetails(forProxyId id: Int, pacId: Int, lockedOnIPs: [String], usage: String, status: String, startDate: Date?, endDate: Date?, createdDate: Date?, createdAtString: String, hasRequestedRefund: Bool) {
        
        for offer in offers {
            
            let proxy = offer.proxies.filter({$0.id == id}).first
            proxy?.lockedOnIPs = lockedOnIPs
            proxy?.usage = usage
            proxy?.startDate = startDate
            proxy?.endDate = endDate
            proxy?.createdDate = createdDate
            proxy?.createdAtString = createdAtString
            proxy?.status = status
            proxy?.pacId = pacId
            proxy?.hasRequestedRefund = hasRequestedRefund
        }
    }
}
