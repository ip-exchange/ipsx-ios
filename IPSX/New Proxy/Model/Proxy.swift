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
    
    var dataUsageProgress: Float {
        let total = Float(proxyPack?.noOfMB ?? "0") ?? 0
        let remaining = Float(proxyDetails?.remainingMB ?? "0") ?? 0
        return remaining <= 0 ? 1 : total <= 0 ? 0 : (total - remaining) / total
    }
    
    var timeLeftProgress: Float {
        if let startDate = proxyDetails?.startDate, let endDate = proxyDetails?.endDate  {
            let total = endDate.timeIntervalSince(startDate)
            let now = Date().timeIntervalSince(startDate)
            return now > total ? 1 : Float(now / total)
        }
        return 0.0
    }


    init(proxyPack: ProxyPack? = nil, proxyDetails: ProxyActivationDetails? = nil, proxySetup: ProxySetup? = nil) {
        
        self.proxyPack = proxyPack
        self.proxyDetails = proxyDetails
        self.proxySetup = proxySetup
    }
}
