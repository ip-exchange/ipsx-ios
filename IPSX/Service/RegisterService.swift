//
//  RegisterService.swift
//  IPSX
//
//  Created by Cristina Virlan on 30/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class RegisterService {
    
    func registerUser(email: String, password: String, ip: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let params: [String: String] = ["email"      : email,
                                        "password"   : password,
                                        "ip"         : ip]
        
        RequestBuilder.shared.executeRequest(requestType: .register, bodyParams: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard data != nil else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func addEthAdress(address: String, alias: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let bodyParams: [String: String] = ["address" : address,
                                            "alias"   : alias]
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .addEthAddress, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            let json = JSON(data: data)
            let ethID    = json["id"].stringValue
            let address  = json["address"].stringValue
            let alias    = json["alias"].stringValue
            let verified = json["verified"].intValue
            let status   = json["status"].stringValue
            
            if ethID == "" || address == "" || alias == "" {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            let ethAddress = EthAddress(ethID: ethID, ethAddress: address, ethAlias: alias, ethValidation: verified, ethStatus: status)
            completionHandler(ServiceResult.success(ethAddress))
        })
    }

}

