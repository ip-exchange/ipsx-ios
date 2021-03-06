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
            request = Request(url:Url.baseApi + Url.loginArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .fbLogin:
            let body = JSON(bodyParams)
            request = Request(url:Url.baseApi + Url.fbLoginArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .resetPassword:
            let body = JSON(bodyParams)
            request = Request(url:Url.baseApi + Url.resetPassArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        case .changePassword:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.changePassArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            }
            
        //Register Requests
            
        case .getPublicIP:
            request = Request(url:Url.baseApi + Url.publicIPArgs, httpMethod: "GET")
            
        case .register:
            let body = JSON(bodyParams)
            request = Request(url:Url.baseApi + Url.registerArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
          
        case .fbRegister:
            let body = JSON(bodyParams)
            request = Request(url:Url.baseApi + Url.fbRegisterArgs, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            
        //User Info Requests
            
        case .getUserCountryList:
            request = Request(url:Url.baseApi + Url.userCountriesArgs, httpMethod: "GET", contentType: ContentType.applicationJSON)
            
        case .updateProfile:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.userInfoArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "PATCH", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .userInfo:
            var url = Url.baseApi + Url.userInfoArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
           
        case .enrollTesting:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.enrollTestingArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .enrollStaking:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.enrollStakingBulkArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .enrollStakingDetails:
            var url = Url.baseApi + Url.enrollStakingArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        //Proxy Requests
            
        case .getProxyCountryList:
            var url = Url.baseApi + Url.proxyCountriesArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
          
        case .retrieveProxyPackages:
            var url = Url.baseApi + Url.proxyPackagesArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .retrieveTestProxyPackage:
            var url = Url.baseApi + Url.proxyTestPackageArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .retrieveProxies:
            var url = Url.baseApi + Url.proxiesArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .createProxy:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.createProxyArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body: body)
            }
            
        //ETH addresses Requests
            
        case .updateEthAddress:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.updateEthAddressArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "PUT", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .deleteEthAddress:
            var url = Url.baseApi + Url.updateEthAddressArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "DELETE", contentType: ContentType.applicationJSON)
            }
            
        case .addEthAddress:
            
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.ethArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            }
         
        case .getEthAddress:
            var url = Url.baseApi + Url.ethEnrolmentsArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
        
        //Token Requests
            
        case .requestTokens:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.tokenRequestArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body:body)
            }
            
        case .getTokenRequestList:
            var url = Url.baseApi + Url.tokenRequestArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .getDepositList:
            var url = Url.baseApi + Url.depositArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .createDeposit:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.depositArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .cancelDeposit:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.cancelDepositArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "PUT", contentType: ContentType.applicationJSON, body: body)
            }
        
        // Settings 
        
        case .getSettings:
            var url = Url.baseApi + Url.metaArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
            }
            
        case .updateSettings:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.metaArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "PUT", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .generalSettings:
        var url = Url.baseApi + Url.generalSettingsArgs
        if let params = urlParams as? [String: String] {
            url = url.replaceKeysWithValues(paramsDict: params)
            request = Request(url:url, httpMethod: "GET", contentType: ContentType.applicationJSON)
        }
            
        case .deleteAccount:
            let body = JSON(bodyParams)
            var url = Url.baseApi + Url.deleteAccountArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "DELETE", contentType: ContentType.applicationJSON, body: body)
            }
            
        case .abortDeleteAccount:
            var url = Url.baseApi + Url.abortDeleteAccountArgs
            if let params = urlParams as? [String: String] {
                url = url.replaceKeysWithValues(paramsDict: params)
                request = Request(url:url, httpMethod: "POST", contentType: ContentType.applicationJSON)
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
    
    /// urlParams should be [String: String]
    
    public func executeRequest(requestType:IPRequestType, urlParams: [String: String] = [:], bodyParams: [String: Any] = [:], completion:@escaping (Error?, Data?)->Void) {
        
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
                completion(CustomError.wrongPassword, data)
               
            // is not configured to return 402 -> it will return 500
            case .deleteAccount:
                print(NSDate(), "\(requestType)" + "Request failed. Wrong password")
                completion(CustomError.wrongPassword, data)
                
            default:
                print(NSDate(), "\(requestType)" + "Request failed with status code:", statusCode)
                completion(CustomError.statusCodeNOK(statusCode), data)
            }

        case 403:
            
            switch requestType {
                
            case .login:
                print(NSDate(), "\(requestType)" + "Request failed. Invalid Login. Email not confirmed")
                completion(CustomError.invalidLogin, data)
                
            case .resetPassword:
                print(NSDate(), "\(requestType)" + "Request failed. Can't reset password from IPSX app.")
                completion(CustomError.notPossible, data)
                
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
            
        case 429:
            
            switch requestType {
                
            case .fbLogin:
                print(NSDate(), "\(requestType)" + "Request failed. This user has not registered with Facebook")
                completion(CustomError.notFound, data)
                
            default:
                print(NSDate(), "\(requestType)" + "Request failed with status code:", statusCode)
                completion(CustomError.statusCodeNOK(statusCode), data)
            }
            
        case 430:
            
            switch requestType {
                
            case .addEthAddress, .fbRegister, .register:
                print(NSDate(), "\(requestType)" + "Request failed. This record already exists")
                completion(CustomError.alreadyExists, data)
                
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
