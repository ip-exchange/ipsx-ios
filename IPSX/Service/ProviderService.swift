//
//  ProviderService.swift
//  IPSX
//
//  Created by Cristina Virlan on 14/09/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation
import IPSXNetworkingFramework

class ProviderService {
    
    func getProviderStatus(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.getProviderDetails, urlParams: urlParams)
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
            let jsonSubmission = json["submission"]
            let statusString = jsonSubmission["status"].stringValue
            
            if let status = ProviderStatus(rawValue: statusString) {
                completionHandler(ServiceResult.success(status))
            }
            else {
                print("Error: Provider submission status doesn't match with internal mapping")
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
            }
        })
    }
}
