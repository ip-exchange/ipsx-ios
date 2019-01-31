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
        
        let bodyParams: [String: String] = ["email"    : email,
                                            "password" : password]
        
        let request = createRequest(requestType: RequestType.login, bodyParams: bodyParams)
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
            let userId = json["userId"].stringValue
            let accessToken = json["id"].stringValue
            
            //Store access details in keychain
            UserManager.shared.storeAccessDetails(userId: userId, accessToken: accessToken, email: email, password: password)
            
            LegalPersonService().getCompanyDetails(completionHandler: { result in
                
                switch result {
                case .success(let company):
                    UserManager.shared.company = company as? Company
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

                case .failure(let error):
                    completionHandler(ServiceResult.failure(error))
                }
            })

        })
    }
        
    func resetPassword(email: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let bodyParams: [String: String] = ["email" : email]
        let request = createRequest(requestType: RequestType.resetPassword, bodyParams: bodyParams)
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
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func changePassword(oldPassword: String, newPassword: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let bodyParams: [String: String] = ["oldPassword"             : oldPassword,
                                            "newPassword"             : newPassword,
                                            "newPasswordConfirmation" : newPassword]
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.changePassword, urlParams: urlParams, bodyParams: bodyParams)
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
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func getNewAccessToken(errorHandler: @escaping (Error?)->Void, successHandler:@escaping () -> ()) {
        
        if UserManager.shared.isLoggedInWithFB {
            
            SocialIntegrationService().facebook(requestType: RequestType.fbLogin, fbToken: UserManager.shared.facebookToken, completionHandler: { result in
                
                switch result {
                    
                case .success(_):
                    successHandler()
                    
                case .failure(_):
                    NotificationCenter.default.post(name: .userDeleted, object: nil)
                }
            })
        }
        else {
            login(email: UserManager.shared.email, password: UserManager.shared.password, completionHandler: { result in
                
                switch result {
                    
                case .success(_):
                    successHandler()
                    
                case .failure(_):
                    NotificationCenter.default.post(name: .userDeleted, object: nil)
                }
            })
        }
    }
    
    func logout(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.logout, urlParams: urlParams)
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
            completionHandler(ServiceResult.success(true))
        })
    }
}



