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
    
    public func createRequest(requestType:IPRequestType, urlParams: [String: Any] = [:], bodyParams: [String: Any] = [:]) -> URLRequest? {
        
        var urlRequest: URLRequest?
        var request: Request?
        var postData: Data?
        
        switch requestType {
            
        case .getPublicIP:
            request = Request(url:Url.publicIP, httpMethod: "GET")
            
        case .register:
            let body = JSON(bodyParams)
            request = Request(url:Url.base + Url.registerArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .getUserCountryList:
            request = Request(url:Url.base + Url.userCountriesArgs, httpMethod: "GET", contentType: ContentType.applicationJSON)
            
        case .updateProfile:
            let body = JSON(bodyParams)
            var url = Url.base + Url.userInfoArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "PUT", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .getProxyCountryList:
            var url = Url.base + Url.proxyCountriesArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
    
        case .addEthAddress:
            
            let body = JSON(bodyParams)
            var url = Url.base + Url.ethAddressArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            }
         
        case .getETHaddresses:
            var url = Url.base + Url.ethAddressArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .login:
            let body = JSON(bodyParams)
            request = Request(url:Url.base + Url.loginArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .logout:
            var url = Url.base + Url.logoutArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON)
            }
            
        case .retrieveProxies:
            var url = Url.base + Url.proxiesArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .userInfo:
            var url = Url.base + Url.userInfoArgs
            if let params = urlParams as? [String: String] {
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
    
    public func executeRequest(requestType:IPRequestType, urlParams: [String: Any] = [:], bodyParams: [String: Any] = [:], completion:@escaping (Error?, Data?)->Void) {
        
        let requestManager = IPRequestManager.shared
        if let request = requestManager.createRequest(requestType: requestType, urlParams: urlParams, bodyParams: bodyParams) {
            
            requestManager.session.dataTask(with: request , completionHandler: { data, response, error in
                
                if let error = error {
                    completion(error, data)
                }
                else if let httpResponse = response as? HTTPURLResponse , let data = data {
                    
                    let statusCode = httpResponse.statusCode
                    switch statusCode {
                        
                    case 200, 204:
                        print(NSDate(),"\(requestType)" + "Request succeeded")
                        completion(nil, data)
                        
                    //TODO (CVI): we should use one statusCode for each request when expired token
                    //TODO (CVI): getNewAccessToken() should be called here
                        
                    case 401 where requestType == .retrieveProxies || requestType == .userInfo:
                        print(NSDate(), "\(requestType)" + "Request failed. Expired token ")
                        completion(CustomError.expiredToken, data)
                        
                    case 422 where requestType == .addEthAddress:
                        print(NSDate(), "\(requestType)" + "Request failed. This ETH address is already used ")
                        completion(CustomError.ethAddressAlreadyUsed, data)
                        
                    default:
                        print(NSDate(), "\(requestType)" + "Request failed with status code: ", statusCode)
                        completion(CustomError.statusCodeNOK(statusCode), data)
                    }
                }
            }).resume()
        }
    }
}
