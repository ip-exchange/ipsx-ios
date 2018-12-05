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
    
    let usdSubtotal: String
    let usdVat: String
    let usdTotal: String
    
    let ipsxSubtotal: String
    let ipsxVat: String
    let ipsxTotal: String
    
    init(usdSubtotal: Double, usdVat: Double, usdTotal: Double, ipsxSubtotal: Double, ipsxVat: Double, ipsxTotal: Double) {
        
        self.usdSubtotal = usdSubtotal.cleanString
        self.usdVat = usdVat.cleanString
        self.usdTotal = usdTotal.cleanString
        
        self.ipsxSubtotal = ipsxSubtotal.cleanString
        self.ipsxVat = ipsxVat.cleanString
        self.ipsxTotal = ipsxTotal.cleanString
    }
    
    func setOffers(offers: [Offer]) {
        self.offers = offers
    }
    
}
