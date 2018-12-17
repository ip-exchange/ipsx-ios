//
//  Options.swift
//  IPSX
//
//  Created by Cristina Virlan on 22/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

public struct GeneralSettings {

    //per day
    var maxTokenRequests: Int = 5
    
    var maxETHaddresses: Int = 5
    var depositMin: Int = 20
    var depositMax: Int = 5000
    var depositEthAddress: String?
    var stakingStatus: Bool = false
    var stakingEndDate: String?
    var proxyDaysRefund: String?
    
    init(depositMin: Int, depositMax: Int, maxETHaddresses: Int, maxTokenRequests: Int, depositEthAddress: String? = nil, proxyDaysRefund: String? = nil) {
        
        self.depositMin = depositMin
        self.depositMax = depositMax
        self.maxETHaddresses = maxETHaddresses
        self.maxTokenRequests = maxTokenRequests
        self.depositEthAddress = depositEthAddress
        self.proxyDaysRefund = proxyDaysRefund
    }
    
    init() { }
}
