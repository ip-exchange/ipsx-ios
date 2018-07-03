//
//  RequestBuilder.swift
//  Test
//
//  Created by Cristina Virlan on 13/02/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//
import Foundation

public class RequestBuilder: NSObject, URLSessionDelegate {
    
    public static let shared = RequestBuilder()
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
        
        //Login Requests
            
        case .login:
            let body = JSON(bodyParams)
            request = Request(url:Url.base + Url.loginArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .fbLogin:
            let body = JSON(bodyParams)
            request = Request(url:Url.base + Url.fbLoginArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .resetPassword:
            let body = JSON(bodyParams)
            request = Request(url:Url.base + Url.resetPassArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .changePassword:
            let body = JSON(bodyParams)
            var url = Url.base + Url.changePassArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            }
            
        //Register Requests
            
        case .getPublicIP:
            request = Request(url:Url.publicIP, httpMethod: "GET")
            
        case .register:
            let body = JSON(bodyParams)
            request = Request(url:Url.base + Url.registerArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
          
        case .fbRegister:
            let body = JSON(bodyParams)
            request = Request(url:Url.base + Url.fbRegisterArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        //User Info Requests
            
        case .getUserCountryList:
            request = Request(url:Url.base + Url.userCountriesArgs, httpMethod: "GET", contentType: ContentType.applicationJSON)
            
        case .updateProfile:
            let body = JSON(bodyParams)
            var url = Url.base + Url.userInfoArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "PUT", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .userInfo:
            var url = Url.base + Url.userInfoArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
           
        case .enrollTesting:
            let body = JSON(bodyParams)
            var url = Url.base + Url.enrollTestingArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .enrollStaking:
            let body = JSON(bodyParams)
            var url = Url.base + Url.enrollStakingBulkArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .enrollStakingDetails:
            var url = Url.base + Url.enrollStakingArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .getSettings:
            var url = Url.base + Url.metaArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .updateSettings:
            let body = JSON(bodyParams)
            var url = Url.base + Url.metaArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "PUT", contentType: ContentType.applicationJSON, body: body)
            }
            
        //Proxy Requests
            
        case .getProxyCountryList:
            var url = Url.base + Url.proxyCountriesArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
          
        case .retrieveProxyPackages:
            var url = Url.base + Url.proxyPackagesArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .retrieveTestProxyPackage:
            var url = Url.base + Url.proxyTestPackageArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .retrieveProxies:
            var url = Url.base + Url.proxiesArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .createProxy:
            let body = JSON(bodyParams)
            var url = Url.base + Url.createProxyArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body: body)
            }
            
        //ETH addresses Requests
            
        case .updateEthAddress:
            let body = JSON(bodyParams)
            var url = Url.base + Url.updateEthAddressArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "PUT", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .deleteEthAddress:
            var url = Url.base + Url.updateEthAddressArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "DELETE", contentType: ContentType.applicationJSON)
            }
            
        case .addEthAddress:
            
            let body = JSON(bodyParams)
            var url = Url.base + Url.ethArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            }
         
        case .getEthAddress:
            var url = Url.base + Url.ethEnrolmentsArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
        
        //Token Requests
            
        case .requestTokens:
            
            let body = JSON(bodyParams)
            var url = Url.base + Url.tokenRequestArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            }
            
        case .getTokenRequestList:
            
            var url = Url.base + Url.tokenRequestArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
        
        //Options
        
        case .options:
        
        var url = Url.base + Url.optionsArgs
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
        
        let requestBuilder = RequestBuilder.shared
        if let request = requestBuilder.createRequest(requestType: requestType, urlParams: urlParams, bodyParams: bodyParams) {
            
            requestBuilder.session.dataTask(with: request , completionHandler: { data, response, error in
                
                if let error = error {
                    completion(error, data)
                }
                else if let httpResponse = response as? HTTPURLResponse , let data = data {
                    
                    let statusCode = httpResponse.statusCode
                    self.handleResponse(statusCode: statusCode, requestType: requestType, data: data, completion: completion)
                }
            }).resume()
        }
    }
    
    func handleResponse(statusCode: Int, requestType: IPRequestType, data: Data, completion:@escaping (Error?, Data?)->Void) {
        
        switch statusCode {
            
        case 200, 204:
            print(NSDate(),"\(requestType)" + "Request succeeded")
            completion(nil, data)
            
        case 401:
            
            switch requestType {
                
            case .login:
                print(NSDate(), "\(requestType)" + "Request failed. Login failed")
                completion(CustomError.loginFailed, data)
                
            case .register:
                print(NSDate(), "\(requestType)" + "Request failed. Register failed")
                completion(CustomError.statusCodeNOK(statusCode), data)
                
            default:
                print(NSDate(), "\(requestType)" + "Request failed. Expired token")
                completion(CustomError.expiredToken, data)
            }
            
        case 402:
            
            switch requestType {
                
            case .changePassword:
                print(NSDate(), "\(requestType)" + "Request failed. User specified wrong old password")
                completion(CustomError.wrongOldPassword, data)
                
            default:
                print(NSDate(), "\(requestType)" + "Request failed with status code:", statusCode)
                completion(CustomError.statusCodeNOK(statusCode), data)
            }

        case 403:
            
            switch requestType {
                
            case .login:
                print(NSDate(), "\(requestType)" + "Request failed. Invalid Login. Email not confirmed")
                completion(CustomError.invalidLogin, data)
                
            default:
                print(NSDate(), "\(requestType)" + "Request failed with status code:", statusCode)
                completion(CustomError.statusCodeNOK(statusCode), data)
            }

        case 405:
            
            switch requestType {
                
            case .login, .fbLogin, .resetPassword:
                print(NSDate(), "\(requestType)" + "Request failed. Invalid Login. User deleted.")
                completion(CustomError.userDeleted, data)
                
            default:
                print(NSDate(), "\(requestType)" + "Request failed with status code:", statusCode)
                completion(CustomError.statusCodeNOK(statusCode), data)
            }
            
        case 422:
            
            switch requestType {
                
            case .addEthAddress, .updateEthAddress, .fbRegister, .register:
                print(NSDate(), "\(requestType)" + "Request failed. This record already exists")
                completion(CustomError.alreadyExists, data)
               
            case .fbLogin:
                print(NSDate(), "\(requestType)" + "Request failed. This user has not registered with Facebook")
                completion(CustomError.notFound, data)
                
            default:
                print(NSDate(), "\(requestType)" + "Request failed with status code:", statusCode)
                completion(CustomError.statusCodeNOK(statusCode), data)
            }
        
        default:
            print(NSDate(), "\(requestType)" + "Request failed with status code:", statusCode)
            completion(CustomError.statusCodeNOK(statusCode), data)
        }
    }
}
