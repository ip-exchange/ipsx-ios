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
    case pending      = 1
    case confirmed    = 2
}

enum DestinyType: Int {
    
    case requester = 0
    case provider  = 1
}

enum UserType: Int {
    
    case individual = 0
    case legal      = 1
}

struct UserInfo {
    
    var deleteAccountState: DeleteAccountState = .notRequested
    
    enum KycStatus: Int {
        
        case Registered = 0
        case Approved   = 1
        case Pending    = 2
        case Incomplete = 3
        case Waiting    = 4
        case Rejected   = 5
        case Accepted   = 6
    }
    
    let kycStausedDic: [Int : String] = [KycStatus.Registered.rawValue : "Registered Status Text",
                                         KycStatus.Approved.rawValue   : "Approved Status Text",
                                         KycStatus.Pending.rawValue    : "Pending Status Text",
                                         KycStatus.Incomplete.rawValue : "Incomplete Status Text",
                                         KycStatus.Waiting.rawValue    : "Waiting Status Text",
                                         KycStatus.Rejected.rawValue   : "Rejected Status Text",
                                         KycStatus.Accepted.rawValue   : "Accepted Status Text",
                                         ]

    var firstName: String
    var middleName: String
    var lastName: String
    var telegram: String
    var countryID: String
    var email: String
    var proxyTest: String
    var balance: Double
    var kycStatusString: String = "Unknown Status Text".localized
    var kycStatus: KycStatus
    var socialName: String?
    var source: String?
    var refferalCode: String?
    var deleteAccountDate: Date?
    var hasOptedForLegal: Bool
    
    //TODO (some new minion in the future): Refactor the constructor to accept a dictionary
    init(firstName: String = "", middleName: String = "",lastName: String = "",
         telegram: String = "", countryID: String = "", email: String = "", proxyTest: String = "", balance: Double = 0, kycStatus: Int = -1, socialName: String? = nil, source: String? = nil, refferalCode: String? = nil, deleteAccountDate: Date? = nil, pendingDeleteAccount: Bool = false, isLegalPerson: Bool) {
        
        self.firstName     = firstName
        self.middleName    = middleName
        self.lastName      = lastName
        self.telegram      = telegram
        self.countryID     = countryID
        self.email         = email
        self.proxyTest     = proxyTest
        self.balance       = balance
        self.socialName    = socialName
        self.source        = source
        self.refferalCode  = refferalCode
        self.hasOptedForLegal = isLegalPerson
        
        self.deleteAccountDate = deleteAccountDate
        self.kycStatus = KycStatus(rawValue: kycStatus) ?? .Registered
        
        if let statusString = kycStausedDic[kycStatus] {
            self.kycStatusString = statusString.localized
        }
        
        if deleteAccountDate != nil {
            deleteAccountState = .confirmed
        }
        else if pendingDeleteAccount {
            deleteAccountState = .pending
        }
    }
}
