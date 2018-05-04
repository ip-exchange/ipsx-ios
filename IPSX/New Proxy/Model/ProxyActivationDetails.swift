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
    var remainingMB: String
    var remainingDuration: String
    var status: String
    
    init(startDate: Date? = nil, endDate: Date? = nil, country: String = "", userIP: String = "", remainingMB: String = "", remainingDuration: String = "", status: String = "") {
        
        self.startDate = startDate
        self.endDate = endDate
        self.country = country
        self.userIP = userIP
        self.remainingMB = remainingMB
        self.remainingDuration = remainingDuration
        self.status = status
    }
}
