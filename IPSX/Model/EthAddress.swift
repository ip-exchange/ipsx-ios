//
//  EthAddress.swift
//  IPSX
//
//  Created by Cristina Virlan on 07/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

enum EthAddressState: Int {
    
    case pending = 0
    case verified = 1
    case rejected = 2
}

struct EthAddress {
    
    var ethID: String
    var address: String
    var alias: String
    var validationState: EthAddressState = .pending
    var status: String
    
    init(ethID: String = "", ethAddress: String = "", ethAlias: String = "", ethValidation: Int = 0, ethStatus: String = "") {
        
        self.ethID    = ethID != "" ? ethID : "N/A"
        self.address  = ethAddress != "" ? ethAddress : "N/A"
        self.alias    = ethAlias
        self.status   = ethStatus != "" ? ethStatus : "N/A"
        
        if let validation = EthAddressState(rawValue: ethValidation) {
            self.validationState = validation
        }
    }
}
