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
    var isTestProxy: Bool = false
    
    var dataUsageProgress: Float {
        let total = Float(proxyPack?.noOfMB ?? "0") ?? 0
        let used = Float(proxyDetails?.usedMB ?? "0") ?? 0
        return used <= 0 ? 0 : total <= 0 ? 0 : used / total
    }
    
    var timeLeftProgress: Float {
        if let startDate = proxyDetails?.startDate, let endDate = proxyDetails?.endDate  {
            let total = endDate.timeIntervalSince(startDate)
            let now = Date().timeIntervalSince(startDate)
            return now > total ? 1 : Float(now / total)
        }
        return 0.0
    }


    init(proxyPack: ProxyPack? = nil, proxyDetails: ProxyActivationDetails? = nil, proxySetup: ProxySetup? = nil, isTestProxy: Bool = false) {
        
        self.proxyPack    = proxyPack
        self.proxyDetails = proxyDetails
        self.proxySetup   = proxySetup
        self.isTestProxy  = isTestProxy
    }
}
