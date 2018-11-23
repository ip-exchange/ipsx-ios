//
//  ProxyService.swift
//  IPSX
//
//  Created by Cristina Virlan on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class ProxyService {
    
    func getProxyCountryList(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.getProxyCountryList, urlParams: urlParams)
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
            let json = JSON(data)
            var countries: [String] = []
            if let countryList = json["countries"].arrayObject as? [String] {
                countries = countryList
            }
            completionHandler(ServiceResult.success(countries))
        })
    }
    
}
