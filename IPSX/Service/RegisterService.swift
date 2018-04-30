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
    
    func registerUser(forParams email: String, password: String, ip: String, completion:@escaping (_ error: Error?, _ userId: String)->()) {
        
        let params: [String: String] = ["email"      : email,
                                        "password"   : password,
                                        "email_token": "",
                                        "ip"         : ""]
        
        IPRequestManager.shared.executeRequest(requestType: .register, params: params, completion: { error, data in
            
            guard error == nil else {
                completion(error, "")
                return
            }
            guard let data = data else {
                completion(CustomError.noData, "")
                return
            }
            let json = JSON(data: data)
            let userId = json["id"].stringValue
            
            if userId != "" {
                completion(nil, userId)
            }
            else {
                completion(CustomError.invalidJson, "")
            }
        })
    }
}

