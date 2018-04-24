//
//  IPRequestManager.swift
//  Test
//
//  Created by Cristina Virlan on 13/02/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//
import Foundation
import SwiftyJSON

public class IPRequestManager: NSObject, URLSessionDelegate {
    
    public static let shared = IPRequestManager()
    private override init(){}
    
    public var session : URLSession {
        get{
            let urlconfig = URLSessionConfiguration.default
            urlconfig.timeoutIntervalForRequest = 30
            urlconfig.timeoutIntervalForResource = 30
            return URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
        }
    }
    public var publicIP: String?
    public var privateIP: String?
    
    public func createRequest(requestType:IPRequestType, params: [String: Any] = [:]) -> URLRequest? {
        
        var urlRequest: URLRequest?
        var request: Request?
        var postData: Data?
        
        switch requestType {
            
        case .getPublicIP:
            request = Request(url:Url.publicIP, httpMethod: "GET")
        
        case .getCountryList, .getProxy:
            let body = JSON(params)
            request = Request(url:Url.proxyAPI, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
        }
        
        if let body = request?.body as? JSON {
            do {
                postData = try body.rawData()
            } catch {
                print("Error getting Data from JSON body")
            }
        }
        
        if let request = request {
            
            urlRequest = URLRequest(url:URL(string: request.url)!)
            urlRequest?.httpMethod = request.httpMethod
            urlRequest?.httpBody = postData
            
            if let contentType = request.contentType {
                urlRequest?.addValue(contentType, forHTTPHeaderField: "Content-Type")
            }
        }
        return urlRequest
    }
    
}
