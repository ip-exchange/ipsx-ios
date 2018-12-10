//
//  Proxy.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class Proxy {
    
    var id: Int
    var countryName: String
    var flagUrlName: String
    var sla: Int
    var ipType: String = "" // IPv4, IPv6
    var proxyType: String // Dedicated, Shared
    var features: [String] // ["http(s)", "socks5", "shadowsocks", "vpn"]
    
    init(id: Int, countryName: String, flagUrlName: String, sla: Int, ipType: Int, proxyType: String, features: [String]) {
        
        self.id  = id
        self.countryName = countryName
        self.flagUrlName = flagUrlName
        self.sla = sla
        self.proxyType = proxyType
        self.features = features
        
        if ipType == 4 { self.ipType = "IPv4" }
        if ipType == 6 { self.ipType = "IPv6" }
    }
}
