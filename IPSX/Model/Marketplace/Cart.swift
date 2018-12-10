//
//  Cart.swift
//  IPSX
//
//  Created by Cristina Virlan on 29/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class Cart {
    
    var offers: [Offer] = []
    var summary: Summary?
    
    func setSummary(summary: Summary) {
        self.summary = summary
    }
    
    func setOffers(offers: [Offer]) {
        self.offers = offers
    }
    
}
