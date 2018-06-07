//
//  LoginService.swift
//  IPSX
//
//  Created by Cristina Virlan on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class LoginService {
    
    func login(email: String?, password: String?, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let email = email, let password = password else {
            completionHandler(ServiceResult.failure(CustomError.invalidParams))
            return
        }
        
        let params: [String: String] = ["email"    : email,
                                        "password" : password]
        
        RequestBuilder.shared.executeRequest(requestType: .login, bodyParams: params, completion: { error, data in
            
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
                    
                case .success(let user):
                    UserManager.shared.userInfo = user as? UserInfo
                    completionHandler(ServiceResult.success(true))
                }
            })
        })
    }
        
    func resetPassword(email: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let bodyParams: [String: String] = ["email" : email]
        
        RequestBuilder.shared.executeRequest(requestType: .resetPassword, bodyParams: bodyParams, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func changePassword(oldPassword: String, newPassword: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let bodyParams: [String: String] = ["oldPassword"             : oldPassword,
                                            "newPassword"             : newPassword,
                                            "newPasswordConfirmation" : newPassword]
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .changePassword, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func getNewAccessToken(errorHandler: @escaping (Error?)->Void, successHandler:@escaping () -> ()) {
        
        if UserManager.shared.isLoggedInWithFB {
            
            SocialIntegrationService().facebook(requestType: .fbLogin, fbToken: UserManager.shared.facebookToken, completionHandler: { result in
                
                switch result {
                    
                case .success(_):
                    successHandler()
                    
                case .failure(let error):
                    errorHandler(error)
                }
            })
        }
        else {
            login(email: UserManager.shared.email, password: UserManager.shared.password, completionHandler: { result in
                
                switch result {
                    
                case .success(_):
                    successHandler()
                    
                case .failure(let error):
                    errorHandler(error)
                }
            })
        }
    }
}



