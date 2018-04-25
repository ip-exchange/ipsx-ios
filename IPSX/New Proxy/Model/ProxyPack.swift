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
    var noOfMB: Int
    var duration: String
    var price: Int
    var iconName: String
    
    init(iconName: String = "", name: String = "", noOfMB: Int = 0, duration: String = "", price: Int = 0) {
        
        self.iconName = iconName
        self.name = name
        self.noOfMB = noOfMB
        self.duration = duration
        self.price = price
    }

}
