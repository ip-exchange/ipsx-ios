//
//  GeneralSettingsService.swift
//  IPSX
//
//  Created by Cristina Virlan on 22/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class GeneralSettingsService {
    
    func retrieveSettings(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
            completionHandler(ServiceResult.failure(CustomError.invalidParams))
            return
        }
        let params: [String: String] =  ["ACCESS_TOKEN" : accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .generalSettings, urlParams: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            guard let jsonArray = JSON(data: data).array, jsonArray.count > 0 else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            
            var settings = GeneralSettings()
            
            for json in jsonArray {
                
                let key = json["key"].stringValue
                let value = json["value"].intValue
                
                switch key {
                case "deposit_min":
                    settings.depositMin = value
                    
                case "deposit_max":
                    settings.depositMax = value
                    
                case "max_eth_addresses_allowed":
                    settings.maxETHaddresses = value
                    
                case "max_token_request_day":
                    settings.maxTokenRequests = value
                    
                default:
                    break
                }
            }
            completionHandler(ServiceResult.success(settings))
        })
    }
}
