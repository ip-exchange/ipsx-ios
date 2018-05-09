//
//  ProxyPack.swift
//  IPSX
//
//  Created by Cristina Virlan on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

struct ProxyPack {
    
    var name: String
    var noOfMB: String
    var duration: String
    var price: String
    var iconName: String
    
    init(iconName: String = "", name: String = "", noOfMB: String = "", duration: String = "", price: String = "") {
        
        self.iconName = iconName
        self.name     = name != "" ? name : "N/A"
        self.noOfMB   = noOfMB != "" ? noOfMB : "N/A"
        self.duration = duration != "" ? duration : "N/A"
        self.price    = price != "" ? price : "N/A"
    }
    
    init() {
        
        self.iconName = "PackCoins"
        self.name = "Test Proxy Name".localized
        self.noOfMB = "20"
        self.duration = "20 min"
        self.price = "0"
    }

}
