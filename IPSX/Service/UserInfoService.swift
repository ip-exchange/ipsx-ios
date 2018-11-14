//
//  UserInfoService.swift
//  IPSX
//
//  Created by Cristina Virlan on 04/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class UserInfoService {
    
    /// - needs userId and accessToken from Keychain as params for the request
    func retrieveUserInfo(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let userId      = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId),
              let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
                
                completionHandler(ServiceResult.failure(CustomError.invalidParams))
                return
        }
        let urlParams: [String: String] =  ["USER_ID"      : userId,
                                            "ACCESS_TOKEN" : accessToken]
        
        let request = createRequest(requestType: RequestType.userInfo, urlParams: urlParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            
            let json = JSON(data: data)
            self.mapResponse(json: json, completionHandler: completionHandler)
        })
    }
    
    private func mapResponse(json:JSON, completionHandler: @escaping (ServiceResult<Any>) -> ()) {

        let deleteConfirmation  = json["self_deleted_at_confirmation"].string
        let selfDeletedAtString = json["self_deleted_at"].stringValue
        let hasOpetdForLegal    = json["intention_company"].intValue == 1 ? true : false
        let hasOpetdForProvider = json["intention_provider"].intValue == 1 ? true : false
        
        let dateFormatter     = DateFormatter.backendResponseParse()
        let deleteAccountDate = dateFormatter.date(from: selfDeletedAtString)
        
        /*
         Bad API (let's hope for something better)
         
         1. No delete action:
         "self_deleted_at_confirmation": null
         
         2. After Delete account action:
         "self_deleted_at_confirmation" != null && "self_deleted_at" == null
         
         3. After confirming the deletion from email:
         "self_deleted_at" != null
         */
        
        var pendingDeleteAccount = false
        
        if deleteConfirmation != nil && deleteAccountDate == nil {
            pendingDeleteAccount = true
        }
        
        let userDict: [String: Any] = [ "first_name":    json["first_name"].stringValue,
                                        "middle_name":   json["middle_name"].stringValue,
                                        "last_name":     json["last_name"].stringValue,
                                        "telegram":      json["telegram"].stringValue,
                                        "country_id":    json["country_id"].stringValue,
                                        "email":         json["email"].stringValue,
                                        "proxy_test":    json["proxy_test"].stringValue,
                                        "ballance":      json["ballance"].doubleValue,
                                        "kyc_status":    json["kyc_status"].intValue,
                                        "social_name":   json["social_name"].stringValue,
                                        "source":        json["source"].stringValue,
                                        "referral_code": json["referral_code"].stringValue,
                                        "delete_account_date":    deleteAccountDate as Any,
                                        "pending_delete_account": pendingDeleteAccount,
                                        "intention_company":      hasOpetdForLegal,
                                        "intention_provider":     hasOpetdForProvider]
        
        let user = UserInfo(userDict: userDict)
        completionHandler(ServiceResult.success(user))
    }
    
    func retrieveETHaddresses(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.getEthAddress, urlParams: urlParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            let json = JSON(data)
            let jsonArray = json["eths"].arrayValue
            
            var ethAddresses: [EthAddress] = []
            for json in jsonArray {

                let ethID    = json["id"].intValue
                let address  = json["address"].stringValue
                let alias    = json["alias"].stringValue
                let verified = json["verified"].intValue
                let status   = json["status"].stringValue
                let created  = json["created_at"].stringValue
                
                let testingEnrolledDate = json["tester"].stringValue
                let stakingEnrolledDate = json["staking"].stringValue

                let dateFormatter = DateFormatter.backendResponseParse()
                
                // null if not enrolled
                let testingDate = dateFormatter.date(from: testingEnrolledDate)
                let stakingDate = dateFormatter.date(from: stakingEnrolledDate)
                let createdDate = dateFormatter.date(from: created)
                
                let ethAddress = EthAddress(ethID: ethID, ethAddress: address, ethAlias: alias, ethValidation: verified, ethStatus: status, testingEnrollmentDate: testingDate, stakingEnrollmentDate: stakingDate, createdDate: createdDate)
                ethAddresses.append(ethAddress)
            }
            ethAddresses.sort { $0.ethID < $1.ethID }
            completionHandler(ServiceResult.success(ethAddresses))
        })
    }
    
    func getUserCountryList(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let request = createRequest(requestType: RequestType.getUserCountryList)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            guard let jsonArray = JSON(data: data).array, jsonArray.count > 0 else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            var countryList: [[String: String]] = []
            
            for json in jsonArray {
                let countryID   = json["id"].stringValue
                let countryName = json["name"].stringValue
                countryList.append([countryID: countryName])
            }
            completionHandler(ServiceResult.success(countryList))
        })
    }
    
    func updateUserProfile(bodyParams: [String: Any], completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.updateProfile, urlParams: urlParams, bodyParams: bodyParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard data != nil else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func updateETHaddress(requestType: String, ethID: Int, alias: String = "", address: String = "", completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["ETH_ID"       : String(ethID),
                                           "USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: String] = ["alias" : alias]
        
        let request = createRequest(requestType: requestType, urlParams: urlParams, bodyParams: bodyParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard data != nil else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func getSettings(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.getSettings, urlParams: urlParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            let json = JSON(data: data)
            let emailNotifValue = json["email_notifications"].stringValue
            let newsletterValue = json["newsletter"].stringValue
            
            let newsletter = newsletterValue != "" ? Newsletter.on : Newsletter.off
            
            if emailNotifValue == EmailNotifications.on || emailNotifValue == EmailNotifications.off {
                
                UserManager.shared.emailNotifications = emailNotifValue == EmailNotifications.on ? true : false
                UserManager.shared.newsletterNotifications = newsletter == Newsletter.on ? true : false
                
                completionHandler(ServiceResult.success((emailNotifValue, newsletter)))
            }
            else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
            }
        })
    }
    
    func updateSettings(emailNotif: Bool, newsletter: Bool, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let emailNotifValue = emailNotif == true ? EmailNotifications.on : EmailNotifications.off
                
        let newsletterValue = newsletter == true ? Date().dateToString(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") : nil
        
        let bodyParams: [String: Any] =  ["email_notifications": emailNotifValue,
                                          "newsletter"         : newsletterValue as Any]
        
        let request = createRequest(requestType: RequestType.updateSettings, urlParams: urlParams, bodyParams: bodyParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard data != nil else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            UserManager.shared.emailNotifications = emailNotif
            UserManager.shared.newsletterNotifications = newsletter
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func getRoles(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.userRoles, urlParams: urlParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            guard let jsonArray = JSON(data: data).array, jsonArray.count > 0 else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            var userRoles: [UserRoles] = []
            
            for json in jsonArray {
                
                let roleID = json["role_id"].intValue
                guard let role = UserRoles(rawValue: roleID) else {
                    completionHandler(ServiceResult.failure(CustomError.invalidJson))
                    return
                }
                userRoles.append(role)
            }
            completionHandler(ServiceResult.success(userRoles))
        })
    }
}
