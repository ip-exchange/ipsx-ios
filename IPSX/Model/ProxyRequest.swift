//
//  ProxyRequest.swift
//  IPSX
//
//  Created by Cristina Virlan on 16/03/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

struct ProxyRequest {
    
    var action: String
    var country: String
    var appUid: String
    var proxyTTL: String
    var proxyTraffic: String
    var authIP: String
    
    init(action: String, country: String, appUid: String, proxyTTL: String, proxyTraffic: String, authIP: String) {
        
        self.action = action
        self.country = country
        self.appUid = appUid
        self.proxyTTL = proxyTTL
        self.proxyTraffic = proxyTraffic
        self.authIP = authIP
    }
}


