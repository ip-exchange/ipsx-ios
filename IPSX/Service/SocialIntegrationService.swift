//
//  SocialIntegrationService.swift
//  IPSX
//
//  Created by Cristina Virlan on 07/06/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation
import FacebookLogin
import FBSDKLoginKit
import CVINetworkingFramework

class SocialIntegrationService {
    
    func facebook(requestType: String, fbToken: String?, newsletter: Bool = true, destiny: DestinyType? = nil, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let fbToken = fbToken else {
            completionHandler(ServiceResult.failure(CustomError.invalidParams))
            return
        }
        
        var bodyParams: [String: Any] = [:]
        
        if requestType == RequestType.fbRegister {
            
            bodyParams = ["token"              : fbToken,
                          "newsletter"         : newsletter as Any,
                          "intention_provider" : destiny?.rawValue as Any]
        }
        else if requestType == RequestType.fbLogin {
            
            bodyParams = ["token" : fbToken]
        }
        
        let request = createRequest(requestType: requestType, bodyParams: bodyParams)
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
            let json        = JSON(data: data)
            let accessToken = json["accessToken"]["id"].stringValue
            let userId      = json["accessToken"]["userId"].stringValue
            
            if accessToken == "" || userId == "" {
                
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            //Store access details in keychain
            UserManager.shared.storeAccessDetails(userId: userId, accessToken: accessToken, facebookToken: fbToken)
            
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
    
    func facebookLogout() {
        
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        LoginManager().logOut()
    }
}
