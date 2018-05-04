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
    
    func retrieveUserInfo(userId: String, accessToken: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
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
        completionHandler(ServiceResult.success(user))
    }
}
