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
    
    var ethID: Int
    var address: String
    var alias: String
    var validationState: EthAddressState = .pending
    
    //"active" / "locked"
    var status: String
    var testingEnrollmentDate: Date?
    var stakingEnrollmentDate: Date?
    
    init(ethID: Int = 0, ethAddress: String = "", ethAlias: String = "", ethValidation: Int = 0, ethStatus: String = "", testingEnrollmentDate: Date? = nil, stakingEnrollmentDate: Date? = nil) {
        
        self.ethID    = ethID 
        self.address  = ethAddress != "" ? ethAddress : "N/A"
        self.alias    = ethAlias
        self.status   = ethStatus != "" ? ethStatus : "N/A"
        
        self.testingEnrollmentDate = testingEnrollmentDate
        self.stakingEnrollmentDate = stakingEnrollmentDate
        
        if let validation = EthAddressState(rawValue: ethValidation) {
            self.validationState = validation
        }
    }
    
    mutating func setTestEnrollmentDate(date: Date?) {
        self.testingEnrollmentDate = date
    }
    
    mutating func setStakingEnrollmentDate(date: Date?) {
        self.stakingEnrollmentDate = date
    }
}
