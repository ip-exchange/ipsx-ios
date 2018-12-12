//
//  FundsService.swift
//  IPSX
//
//  Created by Calin Chitu on 11/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class FundsService {

    func createWaccAddress(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let userId      = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId),
            let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
                
                completionHandler(ServiceResult.failure(CustomError.invalidParams))
                return
        }
        let urlParams: [String: String] =  ["USER_ID"      : userId,
                                            "ACCESS_TOKEN" : accessToken]
        
        let request = createRequest(requestType: RequestType.addWaccAddress, urlParams: urlParams)
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
            let address = json["address"]["public_key"]
            completionHandler(ServiceResult.success(address))
        })
    }

    func retrieveWaccAddress(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let userId      = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId),
            let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
                
                completionHandler(ServiceResult.failure(CustomError.invalidParams))
                return
        }
        let urlParams: [String: String] =  ["USER_ID"      : userId,
                                            "ACCESS_TOKEN" : accessToken]
        
        let request = createRequest(requestType: RequestType.getWaccAddress, urlParams: urlParams)
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
            let address = json["address"]["public_key"].stringValue
            completionHandler(ServiceResult.success(address))
        })
    }

}
