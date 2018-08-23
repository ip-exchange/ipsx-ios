//
//  ProxyActivationDetails.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

struct ProxyActivationDetails {
    
    var startDate: Date?
    var endDate: Date?
    var country: String
    var userIP: String
    var usedMB: String
    var remainingDuration: String
    var status: String //active, expired, close, consumed
    
    init(startDate: Date? = nil, endDate: Date? = nil, country: String = "", userIP: String = "", usedMB: String = "", remainingDuration: String = "", status: String = "") {
        
        self.startDate = startDate
        self.endDate = endDate
        self.country = country != "" ? country : "N/A"
        self.userIP = userIP != "" ? userIP : "N/A"
        self.usedMB = usedMB != "" ? usedMB : "N/A"
        self.remainingDuration = remainingDuration != "" ? remainingDuration : "N/A"
        self.status = status != "" ? status : "N/A"
    }
}
