//
//  OptionsService.swift
//  IPSX
//
//  Created by Cristina Virlan on 22/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import SwiftyJSON

class OptionsService {
    
    func retrieveOptions(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
            completionHandler(ServiceResult.failure(CustomError.invalidParams))
            return
        }
        let params: [String: String] =  ["ACCESS_TOKEN" : accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .options, urlParams: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            guard let jsonArray = JSON(data: data).array else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            
            var options = Options()
            
            for json in jsonArray {
                
                let key = json["key"].stringValue
                let value = json["value"].intValue
                
                switch key {
                case "deposit_min":
                    options.depositMin = value
                    
                case "deposit_max":
                    options.depositMax = value
                    
                case "max_eth_addresses_allowed":
                    options.maxETHaddresses = value
                    
                case "max_token_request_day":
                    options.maxTokenRequests = value
                    
                default:
                    break
                }
            }
            completionHandler(ServiceResult.success(options))
        })
    }
}
