//
//  EnrollmentService.swift
//  IPSX
//
//  Created by Cristina Virlan on 31/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EnrollmentService {
    
    func enrollTesting(ethID: Int, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: Any] = ["usereth_id": ethID,
                                         "status"    : "accepted"]
        
        RequestBuilder.shared.executeRequest(requestType: .enrollTesting, urlParams: urlParams, bodyParams: bodyParams,  completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            let json = JSON(data: data)
            let createdString = json["created_at"].stringValue
            let dateFormatter = DateFormatter.backendResponseParse()
            
            if let createdDate = dateFormatter.date(from: createdString) {
                completionHandler(ServiceResult.success(createdDate))
            }
            else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
            }
        })
    }
    
    func enrollStaking(ethsArray: [Int], completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: [Int]] = ["eths": ethsArray]
        
        RequestBuilder.shared.executeRequest(requestType: .enrollStaking, urlParams: urlParams, bodyParams: bodyParams,  completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard data != nil else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func getEnrollmentDetails(requestType: IPRequestType, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: requestType, urlParams: urlParams,  completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            
            guard let jsonArray = JSON(data: data).array, jsonArray.count > 0 else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            
            var enrollmentDetails: [(Int, Date)] = []
            
            for json in jsonArray {
                
                let status        = json["status"].stringValue
                let ethId         = json["usereth_id"].intValue
                let createdString = json["created_at"].stringValue
                let dateFormatter = DateFormatter.backendResponseParse()
                
                if status == "accepted", let createdDate = dateFormatter.date(from: createdString) {
                    enrollmentDetails.append((ethId, createdDate))
                }
                else {
                    completionHandler(ServiceResult.failure(CustomError.invalidJson))
                }
            }
            completionHandler(ServiceResult.success(enrollmentDetails))
        })
    }
}



