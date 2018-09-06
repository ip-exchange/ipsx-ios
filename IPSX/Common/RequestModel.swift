//
//  RequestModel.swift
//  Test
//
//  Created by Cristina Virlan on 13/02/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

/// CURRENT ENVIRONMENT (DEV / DEMO):
let environment = Environment.dev

enum Environment: String {
    case dev = "DEV"
    case demo = "DEMO"
}

public struct Request {
    
    public var url: String
    public var httpMethod: String
    public var contentType: String?
    public var contentLength: String?
    public var body: Any?
    
    public init(url:String, httpMethod:String, contentType:String? = nil, body: Any? = nil, contentLength: String? = nil) {
        
        self.url = url
        self.httpMethod = httpMethod
        self.contentType = contentType
        self.body = body
        self.contentLength = contentLength
    }
}

public struct Url {

    public static let termsUrl     = "https://ip.sx/dist/IPSX-Terms-of-Service.pdf"
    
    // DEV ENV:
    public static let baseDEVApi    = "http://devapi.ip.sx:3000/api"
    public static let pacBaseUrlDEV = "https://devapp.ip.sx/proxy/pac/"
    public static let faqUrlDev     = "https://devapp.ip.sx/webview/faq/staking"

    // DEMO ENV:
    public static let baseDEMOApi    = "https://api.ipsx.io/api"
    public static let pacBaseUrlDEMO = "https://demo.ip.sx/proxy/pac/"
    public static let faqUrlDemo     = "https://demo.ip.sx/webview/faq/staking"

    public static var baseUrl: String {
        get {
            switch environment {
            case .dev:  return "https://devapp.ip.sx"
            case .demo: return "https://demo.ip.sx"
            }
        }
    }

    public static var baseApi: String {
        get {
            switch environment {
            case .dev:
                return baseDEVApi
            case .demo:
                return baseDEMOApi
            }
        }
    }
    
    public static var pacBaseUrl: String {
        get {
            switch environment {
            case .dev:
                return pacBaseUrlDEV
            case .demo:
                return pacBaseUrlDEMO
            }
        }
    }
    
    public static var faqPageUrl: String {
        get { return baseUrl + "/webview/faq/staking" }
    }

    public static var referalCodeUrl: String {
        get { return baseUrl + "/register?referral=" }
    }
    
    public static let publicIPArgs           = "/Users/ip"
    public static let registerArgs           = "/Users"
    public static let fbRegisterArgs         = "/Users/social/register/facebook"
    public static let userCountriesArgs      = "/countries"
    public static let proxyCountriesArgs     = "/proxies/countries?access_token=%ACCESS_TOKEN%"
    public static let ethEnrolmentsArgs      = "/Users/%USER_ID%/eths/enrolments?access_token=%ACCESS_TOKEN%"
    public static let ethArgs                = "/Users/%USER_ID%/eths?access_token=%ACCESS_TOKEN%"
    public static let updateEthAddressArgs   = "/Users/%USER_ID%/eths/%ETH_ID%?access_token=%ACCESS_TOKEN%"
    public static let loginArgs              = "/Users/auth"
    public static let fbLoginArgs            = "/Users/social/login/facebook"
    public static let resetPassArgs          = "/Users/reset"
    public static let changePassArgs         = "/Users/%USER_ID%/changePassword?access_token=%ACCESS_TOKEN%"
    public static let submitLegalArgs        = "/Users/%USER_ID%/companies/aws-store?access_token=%ACCESS_TOKEN%"
    public static let proxiesArgs            = "/Users/%USER_ID%/proxies?access_token=%ACCESS_TOKEN%"
    public static let createProxyArgs        = "/Users/%USER_ID%/proxies/create-via-package?access_token=%ACCESS_TOKEN%"
    public static let proxyPackagesArgs      = "/packages/admin/paid?access_token=%ACCESS_TOKEN%"
    public static let proxyTestPackageArgs   = "/packages/admin/test?access_token=%ACCESS_TOKEN%"
    public static let userInfoArgs           = "/Users/%USER_ID%?access_token=%ACCESS_TOKEN%"
    public static let tokenRequestArgs       = "/Users/%USER_ID%/token_requests?access_token=%ACCESS_TOKEN%"
    public static let depositArgs            = "/Users/%USER_ID%/deposits?access_token=%ACCESS_TOKEN%"
    public static let cancelDepositArgs      = "/Users/%USER_ID%/deposits/%DEPOSIT_ID%?access_token=%ACCESS_TOKEN%"
    public static let generalSettingsArgs    = "/settings?access_token=%ACCESS_TOKEN%"
    public static let deleteAccountArgs      = "/Users/%USER_ID%/delete/queue?access_token=%ACCESS_TOKEN%"
    public static let abortDeleteAccountArgs = "/Users/%USER_ID%/delete/queue/cancel?access_token=%ACCESS_TOKEN%"
    public static let enrollTestingArgs      = "/Users/%USER_ID%/testers?access_token=%ACCESS_TOKEN%"
    public static let enrollStakingBulkArgs  = "/Users/%USER_ID%/stakings/bulk?access_token=%ACCESS_TOKEN%"
    public static let enrollStakingArgs      = "/Users/%USER_ID%/stakings?access_token=%ACCESS_TOKEN%"
    public static let metaArgs               = "/Users/%USER_ID%/meta?access_token=%ACCESS_TOKEN%"
    public static let companyArgs            = "/Users/%USER_ID%/companies?access_token=%ACCESS_TOKEN%"
}

public enum ServiceResult<T> {
    
    case success(T)
    case failure(Error)
}

public enum CustomError: Error {
    
    case noData
    case invalidJson
    case statusCodeNOK(Int)
    case expiredToken
    case otherError(Error)
    case getPublicIP
    case notSuccessful
    case invalidParams
    case alreadyExists
    case notFound
    case wrongPassword
    case loginFailed
    case invalidLogin
    case userDeleted
    case notPossible
    
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "There was no data on the server response."
            
        case .invalidJson:
            return "Error parsing the JSON response from the server."
            
        case .statusCodeNOK(let statusCode):
            return "Error status code:" + "\(statusCode)"
            
        case .getPublicIP:
            return "Get Public IP Error"
            
        case .notSuccessful:
            return "Request result: success = false"
            
        case .otherError(let err):
            return err.localizedDescription
            
        default:
            return self.localizedDescription
        }
    }
    public var errorCode: String {
        return self.errorCode
    }
}


public enum IPRequestType: Int {
    
    case getPublicIP
    case getUserCountryList
    case register
    case fbRegister
    case getCompany
    case submitLegalPersonDetails
    
    case login
    case fbLogin
    
    case resetPassword
    case changePassword
    
    case retrieveProxies
    case createProxy
    case retrieveProxyPackages
    case retrieveTestProxyPackage
    case getProxyCountryList
    
    case userInfo
    case updateProfile
    case deleteAccount
    case abortDeleteAccount
    
    case requestTokens
    case getDepositList
    case createDeposit
    case cancelDeposit
    
    case addEthAddress
    case getEthAddress
    case updateEthAddress
    case deleteEthAddress
    
    case getTokenRequestList
    case enrollTesting
    case enrollStaking
    case enrollStakingDetails
    
    case getSettings
    case updateSettings
    case generalSettings
}

public struct ContentType {
    
    public static let applicationJSON = "application/json"
    public static let multipart = "multipart/form-data; boundary=\(boundary)"
}

public struct KeychainKeys {
    
    public static let accessToken   = "ACCESS_TOKEN_KEY"
    public static let facebookToken = "FACEBOOK_TOKEN_KEY"
    public static let userId        = "USER_ID_KEY"
    public static let password      = "USER_PASSWORD"
    public static let email         = "USER_EMAIL"
}

public struct EmailNotifications {
    
    public static let on = "all"
    public static let off = "disable"
}

enum Newsletter {
    
    case on
    case off
}

var boundary: String {
    get {
        return "----boundary" + UUID().uuidString
    }
}

var contentDisposition: String {
    get {
        return "Content-Disposition: form-data; name=\"%PARAMETER_NAME%\""
    }
}





