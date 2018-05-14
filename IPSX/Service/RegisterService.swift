//
//  RegisterService.swift
//  IPSX
//
//  Created by Cristina Virlan on 30/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterService {
    
    func registerUser(email: String, password: String, ip: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let params: [String: String] = ["email"      : email,
                                        "password"   : password,
                                        "ip"         : ip]
        
        IPRequestManager.shared.executeRequest(requestType: .register, bodyParams: params, completion: { error, data in
            
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
        
        IPRequestManager.shared.executeRequest(requestType: .addEthAddress, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
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
    
    func updateETHaddress(ethID: String, alias: String, address: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["ETH_ID"       : ethID,
                                            "USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: String] = ["address" : address,
                                            "alias"   : alias]
        
        IPRequestManager.shared.executeRequest(requestType: .updateETHaddress, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
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
}

