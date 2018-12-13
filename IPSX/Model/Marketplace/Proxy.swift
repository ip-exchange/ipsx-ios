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
    var startDate: Date?
    var endDate: Date?
    var createdDate: Date?
    var usage: String?
    var status: String? //active, expired, ...
    var lockedOnIPs: [String]?
    
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
    
    func remainingMinutes() -> String {
        
        guard let startDate = startDate, let endDate = endDate else { return "-" }
        let difference = endDate.timeIntervalSince(startDate)
        let minutes = (Int(difference) / 60) % 60
        return "\(minutes)"
    }
}
