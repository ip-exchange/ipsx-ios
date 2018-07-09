//
//  UserInfo.swift
//  IPSX
//
//  Created by Cristina Virlan on 04/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

struct UserInfo {
    
    let kycStausedDic: [Int : String] = [0 : "Registered Status Text",
                                         1 : "Approved Status Text",
                                         2 : "Pending Status Text",
                                         3 : "Incomplete Status Text",
                                         4 : "Waiting Status Text",
                                         5 : "Rejected Status Text",
                                         6 : "Accepted Status Text",
                                         ]
    
    var firstName: String
    var middleName: String
    var lastName: String
    var telegram: String
    var countryID: String
    var email: String
    var proxyTest: String
    var balance: Int
    var kycStatus: String = "Unknown Status Text".localized

    init(firstName: String = "", middleName: String = "",lastName: String = "",
         telegram: String = "", countryID: String = "", email: String = "", proxyTest: String = "", balance: Int = 0, kycStatus: Int = -1) {
        
        self.firstName  = firstName
        self.middleName = middleName
        self.lastName   = lastName
        self.telegram   = telegram
        self.countryID  = countryID
        self.email      = email
        self.proxyTest  = proxyTest
        self.balance    = balance
        if let statusString = kycStausedDic[kycStatus] {
            self.kycStatus = statusString.localized
        }
    }
}
