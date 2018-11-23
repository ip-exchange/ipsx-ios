//
//  Offer.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class Offer {
    
    var id: String
    var priceIPSX: Double
    var priceDollars: Double
    var durationMin: String
    var trafficMB: String
    
    init(id: String, priceIPSX: Double, priceDollars: Double, durationMin: String, trafficMB: String) {
        
        self.id  = id
        self.priceIPSX = priceIPSX
        self.priceDollars = priceDollars
        self.durationMin = durationMin
        self.trafficMB = trafficMB
    }
    
}
