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
    func login(email: String, password: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let params: [String: String] = ["email"    : email,
                                        "password" : password]
        
        IPRequestManager.shared.executeRequest(requestType: .login, params: params, completion: { error, data in
            
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
            completionHandler(ServiceResult.success((userId, accessToken)))
        })
    }
}



