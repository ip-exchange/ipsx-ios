//
//  Proxy.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

struct Proxy {
    
    var proxyPack: ProxyPack?
    var proxyDetails: ProxyActivationDetails?
    var proxySetup: ProxySetup?
    
    init(proxyPack: ProxyPack? = nil, proxyDetails: ProxyActivationDetails? = nil, proxySetup: ProxySetup? = nil) {
        
        self.proxyPack = proxyPack
        self.proxyDetails = proxyDetails
        self.proxySetup = proxySetup
    }
}