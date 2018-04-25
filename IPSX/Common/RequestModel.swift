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
    public static var proxyAPI = "https://share.ip.sx/api/"
    public static let pacServer = "http://192.168.0.124:8000/index.php?proxy_type=%PROXY_TYPE%&ip=%IP%&port=%PORT%"
}

public enum ServiceResult<T> {
    
    case success(T)
    case failure(Error)
}

public enum CustomError: LocalizedError {
    
    case noData
    case invalidJson
    case statusCodeNOK(Int)
    case otherError(Error)
    case getPublicIP
    case notSuccessful
    
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
        }
    }
}

public enum IPRequestType: Int {
    
    case getPublicIP
    case getCountryList
    case getProxy
}

public struct ContentType {
    public static let applicationJSON = "application/json"
}

public struct Constants {
    static let proxyIP = "176.9.60.230"
}


