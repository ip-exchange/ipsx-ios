//
//  RequestModel.swift
//  Test
//
//  Created by Cristina Virlan on 13/02/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

public struct Request {
    
    public var url: String
    public var httpMethod: String
    public var contentType: String?
    public var body: Any?
    
    public init(url:String, httpMethod:String, contentType:String? = nil, body: Any? = nil) {
        
        self.url = url
        self.httpMethod = httpMethod
        self.contentType = contentType
        self.body = body
    }
}

public struct Url {
    
    public static var publicIP = "https://api.ipify.org?format=json"
    public static let base = "http://devapi.ip.sx:3000/api"
    public static let pacBaseUrl = "https://devapp.ip.sx/proxy/pac/"
    public static let registerArgs = "/Users"
    public static let userCountriesArgs = "/countries"
    public static let proxyCountriesArgs = "/proxies/countries?access_token=%ACCESS_TOKEN%"
    public static let ethAddressArgs = "/Users/%USER_ID%/eths?access_token=%ACCESS_TOKEN%"
    public static let updateEthAddressArgs = "/Users/%USER_ID%/eths/%ETH_ID%?access_token=%ACCESS_TOKEN%"
    public static let loginArgs = "/Users/login"
    public static let logoutArgs = "/Users/logout?access_token=%ACCESS_TOKEN%"
    public static let resetPassArgs = "/Users/reset"
    public static let changePassArgs = "/Users/%USER_ID%/changePassword?access_token=%ACCESS_TOKEN%"
    public static let proxiesArgs = "/Users/%USER_ID%/proxies?access_token=%ACCESS_TOKEN%"
    public static let userInfoArgs = "/Users/%USER_ID%?access_token=%ACCESS_TOKEN%"
    public static let tokenRequestArgs = "/Users/%USER_ID%/token_requests?access_token=%ACCESS_TOKEN%"
    public static let optionsArgs = "/options?access_token=%ACCESS_TOKEN%"
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
    case ethAddressAlreadyUsed
    case wrongOldPassword
    case loginFailed
    case invalidLogin
    
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
    public var errorCode: String? {
        return self.errorCode
    }
}


public enum IPRequestType: Int {
    
    case getPublicIP
    case options
    case register
    case login
    case logout
    case resetPassword
    case changePassword
    case retrieveProxies
    case createProxy
    case userInfo
    case updateProfile
    case requestTokens
    case addEthAddress
    case getEthAddress
    case updateEthAddress
    case deleteEthAddress
    case getUserCountryList
    case getProxyCountryList
    case getTokenRequestList
}

public struct ContentType {
    public static let applicationJSON = "application/json"
}

public struct KeychainKeys {
    
    public static let accessToken = "ACCESS_TOKEN_KEY"
    public static let userId      = "USER_ID_KEY"
    public static let password    = "USER_PASSWORD"
    public static let email       = "USER_EMAIL"
}


