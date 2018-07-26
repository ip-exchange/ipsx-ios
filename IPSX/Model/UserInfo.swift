//
//  UserInfo.swift
//  IPSX
//
//  Created by Cristina Virlan on 04/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

enum DeleteAccountState: Int {
    
    case notRequested = 0
    case pending = 1
    case confirmed = 2
}

struct UserInfo {
    
    var deleteAccountState: DeleteAccountState = .notRequested
    
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
    var balance: Double
    var kycStatus: String = "Unknown Status Text".localized
    var socialName: String?
    var refferalCode: String?
    var deleteAccountDate: Date?
    
    //TODO (some new minion in the future): Refactor the constructor to accept a dictionary
    init(firstName: String = "", middleName: String = "",lastName: String = "",
         telegram: String = "", countryID: String = "", email: String = "", proxyTest: String = "", balance: Double = 0, kycStatus: Int = -1, socialName: String? = nil, refferalCode: String? = nil, deleteAccountDate: Date? = nil, pendingDeleteAccount: Bool = false) {
        
        self.firstName    = firstName
        self.middleName   = middleName
        self.lastName     = lastName
        self.telegram     = telegram
        self.countryID    = countryID
        self.email        = email
        self.proxyTest    = proxyTest
        self.balance      = balance
        self.socialName   = socialName
        self.refferalCode = refferalCode
        
        self.deleteAccountDate = deleteAccountDate
        
        if let statusString = kycStausedDic[kycStatus] {
            self.kycStatus = statusString.localized
        }
        
        if deleteAccountDate != nil {
            deleteAccountState = .confirmed
        }
        else if pendingDeleteAccount {
            deleteAccountState = .pending
        }
    }
}
