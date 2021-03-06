//
//  ProxyPack.swift
//  IPSX
//
//  Created by Cristina Virlan on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

struct ProxyPack {
    
    var packId: Int
    var name: String
    var noOfMB: String
    var duration: String
    var price: String
    var iconName: String
    
    init(iconName: String = "", packId: Int = 0, name: String = "", noOfMB: String = "", duration: String = "", price: String = "") {
        
        self.packId   = packId 
        self.iconName = iconName != "" ? iconName : "PackCoins"
        self.name     = name != "" ? name : "N/A"
        self.noOfMB   = noOfMB != "" ? noOfMB : "N/A"
        self.duration = duration != "" ? duration : "N/A"
        self.price    = price != "" ? price : "N/A"
    }
}
