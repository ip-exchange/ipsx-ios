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
    var maxTokenRequests: Int? //using default = 5
    
    var maxETHaddresses: Int? //using default = 5
    var depositMin: Int? //using default = 20
    var depositMax: Int? //using default = 5000
    var depositEthAddress: String?
    
    init(depositMin: Int? = nil, depositMax: Int? = nil, maxETHaddresses: Int? = nil,maxTokenRequests: Int? = nil, depositEthAddress: String? = nil) {
        
        self.depositMin = depositMin
        self.depositMax = depositMax
        self.maxETHaddresses = maxETHaddresses
        self.maxTokenRequests = maxTokenRequests
        self.depositEthAddress = depositEthAddress
    }
}
