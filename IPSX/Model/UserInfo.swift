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

    var firstName: String?
    var middleName: String?
    var lastName: String?
    var telegram: String?
    var countryID: String?
    var email: String?
    var proxyTest: String?
    var balance: Double?
    var kycStatusString: String = "Unknown Status Text".localized
    var kycStatus: KycStatus
    var socialName: String?
    var source: String?
    var refferalCode: String?
    var deleteAccountDate: Date?
    var hasOptedForLegal: Bool?
    var hasOptedForProvider: Bool?
    
    init(userDict: [String: Any]) {
        
        self.firstName     = userDict["first_name"] as? String
        self.middleName    = userDict["middle_name"] as? String
        self.lastName      = userDict["last_name"] as? String
        self.telegram      = userDict["telegram"] as? String
        self.countryID     = userDict["country_id"] as? String
        self.email         = userDict["email"] as? String
        self.proxyTest     = userDict["proxy_test"] as? String
        self.balance       = userDict["ballance"] as? Double
        self.socialName    = userDict["social_name"] as? String
        self.source        = userDict["source"] as? String
        self.refferalCode  = userDict["referral_code"] as? String
        
        self.hasOptedForLegal    = userDict["intention_company"] as? Bool
        self.hasOptedForProvider = userDict["intention_provider"] as? Bool 
        
        self.deleteAccountDate = userDict["delete_account_date"] as? Date
        let kyc = userDict["kyc_status"] as? Int ?? -1
        self.kycStatus = KycStatus(rawValue: kyc) ?? .Registered
        
        if let statusString = kycStausedDic[kyc] {
            self.kycStatusString = statusString.localized
        }
        
        if deleteAccountDate != nil {
            deleteAccountState = .confirmed
        }
        else if userDict["pending_delete_account"] as? Bool == true {
            deleteAccountState = .pending
        }
    }
}
