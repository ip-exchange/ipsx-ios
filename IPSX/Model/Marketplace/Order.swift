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
    var created: Date?
    var lockedOnIp: String
    var offers: [Offer] = []
    var summary: Summary?
    
    init(id: Int, created: Date?, lockedOnIp: String) {
        
        self.id  = id
        self.created = created
        self.lockedOnIp = lockedOnIp
    }
    
    func setOffers(offers: [Offer]) {
        self.offers = offers
    }
    
    func setSummary(summary: Summary) {
        self.summary = summary
    }
}
