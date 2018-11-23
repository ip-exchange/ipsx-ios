//
//  Proxy.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class Proxy {
    
    var id: String
    var countryName: String
    var sla: String
    var ipType: String // IPv4, IPv6
    var proxyType: String // Dedicated, Shared
    var features: [String] // ["http(s)", "socks5", "shadowsocks", "vpn"]
    
    init(id: String, countryName: String, sla: String, ipType: String, proxyType: String, features: [String]) {
        
        self.id  = id
        self.countryName = countryName
        self.sla = sla
        self.ipType = ipType
        self.proxyType = proxyType
        self.features = features
    }
}
