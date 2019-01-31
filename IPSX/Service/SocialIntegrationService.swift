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
    
    func facebook(requestType: String, fbToken: String?, countryID: String = "", newsletter: Bool = true, type: UserType? = nil, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let fbToken = fbToken else {
            completionHandler(ServiceResult.failure(CustomError.invalidParams))
            return
        }
        
        var bodyParams: [String: Any] = [:]
        
        if requestType == RequestType.fbRegister, let type = type  {
            
            let cID = Double(countryID) ?? -1
            bodyParams = ["token"              : fbToken,
                          "country_id"         : cID,
                          "newsletter"         : newsletter as Any,
                          "intention_company"  : type.rawValue]
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
    
    func facebookLogout() {
        
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        LoginManager().logOut()
    }
}
