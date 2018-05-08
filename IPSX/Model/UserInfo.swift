//
//  UserInfo.swift
//  IPSX
//
//  Created by Cristina Virlan on 04/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

struct UserInfo {
    
    var firstName: String
    var middleName: String
    var lastName: String
    var telegram: String
    var countryID: String
    var email: String
    var proxyTest: String
    var ethAddresses: [EthAddress]?
    
    init(firstName: String = "", middleName: String = "",lastName: String = "",
         telegram: String = "", countryID: String = "", email: String = "", proxyTest: String = "") {
        
        self.firstName  = firstName != "" ? firstName : "N/A"
        self.middleName = middleName != "" ? middleName : "N/A"
        self.lastName   = lastName != "" ? lastName : "N/A"
        self.telegram   = telegram != "" ? telegram : "N/A"
        self.countryID  = countryID != "" ? countryID : "N/A"
        self.email      = email != "" ? email : "N/A"
        self.proxyTest  = proxyTest
    }
    
    mutating func setEthAddresses(ethAddresses: [EthAddress]) {
        self.ethAddresses = ethAddresses
    }
}
