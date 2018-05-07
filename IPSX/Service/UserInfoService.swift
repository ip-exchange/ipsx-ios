//
//  UserInfoService.swift
//  IPSX
//
//  Created by Cristina Virlan on 04/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserInfoService {
    
    /// - needs userId and accessToken from Keychain as params for the request
    func retrieveUserInfo(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let userId      = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId),
              let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
                
                completionHandler(ServiceResult.failure(CustomError.invalidParams))
                return
        }
        let params: [String: String] =  ["USER_ID"      : userId,
                                         "ACCESS_TOKEN" : accessToken]
        
        IPRequestManager.shared.executeRequest(requestType: .userInfo, params: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            
            let json = JSON(data: data)
            self.mapResponse(json: json, completionHandler: completionHandler)
        })
    }
    
    private func mapResponse(json:JSON, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let firstName  = json["first_name"].stringValue
        let middleName = json["middle_name"].stringValue
        let lastName   = json["last_name"].stringValue
        let telegram   = json["telegram"].stringValue
        let countryID  = json["country_id"].stringValue
        let email      = json["email"].stringValue
        let proxyTest  = json["proxy_test"].stringValue
        
        let user = UserInfo(firstName: firstName, middleName: middleName, lastName: lastName, telegram: telegram, countryID: countryID, email: email, proxyTest: proxyTest)
        
        //Store User Info
        UserManager.shared.userInfo = user
        
        completionHandler(ServiceResult.success(""))
    }
}
