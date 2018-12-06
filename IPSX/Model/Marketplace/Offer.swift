//
//  Offer.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class Offer {
    
    var id: Int
    var priceIPSX: String
    var priceDollars: String
    var durationMin: String
    var trafficMB: String
    var proxies: [Proxy] = []
    
    var isAvailable = true
    var isActive = true
    
    var isAddedToCart = false
    var isFavourite = false
    
    init(id: Int, priceIPSX: Double, priceDollars: Double, durationMin: String, trafficMB: String) {
        
        self.id  = id
        self.priceIPSX = priceIPSX.cleanString
        self.priceDollars = priceDollars.cleanString
        self.durationMin = durationMin
        self.trafficMB = trafficMB
    }
    
    func setProxies(proxyArray: [Proxy]) {
        self.proxies = proxyArray
    }
    
    func setStatus(isActive: Bool, isAvailable: Bool) {
        
        self.isActive    = isActive
        self.isAvailable = isAvailable
    }
    
    func setCartAndFavStates(isAddedToCart: Bool, isFavourite: Bool) {
        
        self.isAddedToCart = isAddedToCart
        self.isFavourite   = isFavourite
    }
}
