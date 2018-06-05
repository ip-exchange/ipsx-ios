//
//  EnrollmentService.swift
//  IPSX
//
//  Created by Cristina Virlan on 31/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EnrollmentService {
    
    func enrollTesting(ethID: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: String] = ["usereth_id": ethID,
                                            "status" : "accepted"]
        
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
    
    func enrollTestingDelete(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .enrollTestingDelete, urlParams: urlParams,  completion: { error, data in
            
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
    
    func enrollStaking(ethID: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: String] = ["usereth_id": ethID]
        
        RequestBuilder.shared.executeRequest(requestType: .enrollStaking, urlParams: urlParams, bodyParams: bodyParams,  completion: { error, data in
            
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
            
            switch requestType {
                
            case .enrollTestingDetails:
                
                guard let jsonArray = JSON(data: data).array else {
                    completionHandler(ServiceResult.failure(CustomError.invalidJson))
                    return
                }
                
                for json in jsonArray {
                    
                    let status        = json["status"].stringValue
                    let ethAddress    = json["usereth"].stringValue
                    let createdString = json["created_at"].stringValue
                    let dateFormatter = DateFormatter.backendResponseParse()
                    
                    // Only one address can be accepted for Testing
                    if status == "accepted", let createdDate = dateFormatter.date(from: createdString) {
                        completionHandler(ServiceResult.success((ethAddress, createdDate)))
                    }
                    else {
                        completionHandler(ServiceResult.failure(CustomError.invalidJson))
                    }
                }
                
            case .enrollStakingDetails:
                
                guard let jsonArray = JSON(data: data).array else {
                    completionHandler(ServiceResult.failure(CustomError.invalidJson))
                    return
                }
                
                var enrollmentDetails: [(String, Date)] = []
                
                for json in jsonArray {
                    
                    let status        = json["status"].stringValue
                    let ethAddress    = json["usereth"].stringValue
                    let createdString = json["created_at"].stringValue
                    let dateFormatter = DateFormatter.backendResponseParse()
                    
                    if status == "accepted", let createdDate = dateFormatter.date(from: createdString) {
                        enrollmentDetails.append((ethAddress, createdDate))
                    }
                    else {
                        completionHandler(ServiceResult.failure(CustomError.invalidJson))
                    }
                }
                completionHandler(ServiceResult.success(enrollmentDetails))
                
            default:
                break
            }
        })
    }
}



