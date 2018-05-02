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
    
    func registerUser(email: String, password: String, ip: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let params: [String: String] = ["email"      : email,
                                        "password"   : password,
                                        "ip"         : ip]
        
        IPRequestManager.shared.executeRequest(requestType: .register, params: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard data != nil else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            // TODO (CVI): deocamdata nu ne trebuie niciun camp din response
            completionHandler(ServiceResult.success(""))
        })
    }
}

