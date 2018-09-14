//
//  ProviderService.swift
//  IPSX
//
//  Created by Cristina Virlan on 14/09/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class ProviderService {
    
    func getProviderStatus(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .getProviderDetails, urlParams: urlParams, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            let json = JSON(data: data)
            let jsonSubmission = json["submission"]
            let statusString = jsonSubmission["status"].stringValue
            
            if let status = ProviderStatus(rawValue: statusString) {
                completionHandler(ServiceResult.success(status))
            }
            else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
            }
        })
    }
}
