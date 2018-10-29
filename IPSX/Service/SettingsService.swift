//
//  SettingsService.swift
//  IPSX
//
//  Created by Cristina Virlan on 22/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import CVINetworkingFramework

class SettingsService {
    
    func retrieveSettings(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
            completionHandler(ServiceResult.failure(CustomError.invalidParams))
            return
        }
        let urlParams: [String: String] =  ["ACCESS_TOKEN" : accessToken]
        
        let request = createRequest(requestType: IPRequestType.generalSettings, urlParams: urlParams)
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
            
            var settings = GeneralSettings()
            
            for json in jsonArray {
                
                let key         = json["key"].stringValue
                let valueInt    = json["value"].intValue
                let valueString = json["value"].stringValue
                
                switch key {
                case "deposit_min":
                    settings.depositMin = valueInt
                    
                case "deposit_max":
                    settings.depositMax = valueInt
                    
                case "max_eth_addresses_allowed":
                    settings.maxETHaddresses = valueInt
                    
                case "max_token_request_day":
                    settings.maxTokenRequests = valueInt
                    
                case "deposit_eth":
                    settings.depositEthAddress = valueString
                    
                case "system_staking_status":
                    settings.stakingStatus = valueInt == 1 ? true : false
                    
                case "system_staking_end_date":
                    //TODO: This is a date string format that cant be parsed atm, changes to come.
                    settings.stakingEndDate = valueString
                    
                default:
                    break
                }
            }
            completionHandler(ServiceResult.success(settings))
        })
    }
    
    func deleteAccount(password: String? = nil, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        var bodyParams: [String: String] = [:]
        
        if let _ = password { bodyParams["password"] = password }
        
        let request = createRequest(requestType: IPRequestType.deleteAccount, urlParams: urlParams, bodyParams: bodyParams)
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
    
    func abortDeleteAccount(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: IPRequestType.abortDeleteAccount, urlParams: urlParams)
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
}
