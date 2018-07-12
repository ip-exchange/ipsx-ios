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

class SocialIntegrationService {
    
    func facebook(requestType: IPRequestType, fbToken: String?, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let fbToken = fbToken else {
            completionHandler(ServiceResult.failure(CustomError.invalidParams))
            return
        }
        
        let params: [String: String] = ["token" : fbToken]
        
        RequestBuilder.shared.executeRequest(requestType: requestType, bodyParams: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
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
