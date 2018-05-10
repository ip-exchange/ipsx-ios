//
//  LoginService.swift
//  IPSX
//
//  Created by Cristina Virlan on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginService {
    
    /**
     * Return (userId, accessToken)
     */
    func login(email: String?, password: String?, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let email = email, let password = password else {
            completionHandler(ServiceResult.failure(CustomError.invalidParams))
            return
        }
        
        let params: [String: String] = ["email"    : email,
                                        "password" : password]
        
        IPRequestManager.shared.executeRequest(requestType: .login, bodyParams: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            let json = JSON(data: data)
            let userId = json["userId"].stringValue
            let accessToken = json["id"].stringValue
            
            //Store access details in keychain
            UserManager.shared.storeAccessDetails(userId: userId, accessToken: accessToken, email: email, password: password)
            
            //Execute User Info request
            UserInfoService().retrieveUserInfo(completionHandler: { result in
                switch result {
                    
                case .failure(let error):
                    completionHandler(ServiceResult.failure(error))
                    
                case .success(_):
                    completionHandler(ServiceResult.success(true))
                }
            })
        })
    }
    
    func logout(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let params: [String: String] = ["ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        IPRequestManager.shared.executeRequest(requestType: .logout, urlParams: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func getNewAccessToken(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        login(email: UserManager.shared.email, password: UserManager.shared.password, completionHandler: { result in
            
            switch result {
                
            case .success(_):
               completionHandler(ServiceResult.success(true))
                
            case .failure(let error):
                completionHandler(ServiceResult.failure(error))
            }
        })
    }
}



