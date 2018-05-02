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
            
        case .register:
            let body = JSON(params)
            request = Request(url:Url.base + Url.registerArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .login:
            let body = JSON(params)
            request = Request(url:Url.base + Url.loginArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .retrieveProxies:
            var url = Url.base + Url.proxiesArgs
            if let params = params as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
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
    
    public func executeRequest(requestType:IPRequestType, params: [String: Any] = [:], completion:@escaping (Error?, Data?)->Void) {
        
        let requestManager = IPRequestManager.shared
        if let request = requestManager.createRequest(requestType: requestType, params: params) {
            
            requestManager.session.dataTask(with: request , completionHandler: { data, response, error in
                
                if let error = error {
                    completion(error, data)
                }
                else if let httpResponse = response as? HTTPURLResponse , let data = data {
                    
                    let statusCode = httpResponse.statusCode
                    switch statusCode {
                        
                    case 200:
                        print(NSDate(),"\(type(of: self)):\(#function) Request succeeded")
                        completion(nil, data)
                    //TODO (CVI): this statusCode should be different for expired token
                    case 401:
                        print(NSDate(), "\(type(of: self)):\(#function) Request failed. Expired token ")
                        completion(CustomError.expiredToken, data)
                        
                    default:
                        print(NSDate(), "\(type(of: self)):\(#function) Request failed with status code: ", statusCode)
                        completion(CustomError.statusCodeNOK(statusCode), data)
                    }
                }
            }).resume()
        }
    }
}
