//
//  TokenDepositService.swift
//  IPSX
//
//  Created by Cristina Virlan on 08/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class TokenDepositService {
    
    func requestTokens(ethID: Int, amount: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: Any] = ["usereth_id"       : ethID,
                                         "amount_requested" : amount]
        
        RequestBuilder.shared.executeRequest(requestType: .requestTokens, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
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
    
    func getTokenRequestList(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .getTokenRequestList, urlParams: urlParams, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            guard let jsonArray = JSON(data: data).array else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            var tokenRequests: [TokenRequest] = []
            for json in jsonArray {
                
                let ethID = json["usereth_id"].intValue
                let amount = json["amount_requested"].doubleValue.cleanString
                let status = json["status"].stringValue
                
                let createdString = json["created_at"].stringValue
                
                let dateFormatter = DateFormatter.backendResponseParse()
                
                let createdDate = dateFormatter.date(from: createdString)
                
                let tokenRequest = TokenRequest(ethID: ethID, amount: amount, status: status, created: createdDate)
                tokenRequests.append(tokenRequest)
            }
            completionHandler(ServiceResult.success(tokenRequests))
        })
    }
    
    func getDepositList(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .getDepositList, urlParams: urlParams, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            guard let jsonArray = JSON(data: data).array else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            var deposits: [Deposit] = []
            for json in jsonArray {
                deposits.append(self.mapDepositResponse(json: json))
            }
            completionHandler(ServiceResult.success(deposits))
        })
    }
    
    func createDeposit(ethID: Int, amount: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: Any] = ["usereth_id"       : ethID,
                                         "amount_requested" : amount]
        
        RequestBuilder.shared.executeRequest(requestType: .createDeposit, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            let json = JSON(data: data)
            let deposit = self.mapDepositResponse(json: json)
            completionHandler(ServiceResult.success(deposit))
        })
    }
    
    func mapDepositResponse(json: JSON) -> Deposit {
        
        let dateFormatter = DateFormatter.backendResponseParse()
        
        let depositID        = json["id"].intValue
        let ethId            = json["usereth_id"].intValue
        let amountRequested  = json["amount_requested"].doubleValue.cleanString
        let amountReceived   = json["amount_received"].doubleValue.cleanString
        let status           = json["status"].stringValue
        let watchUntilString = json["watch_until"].stringValue
        let watchUntilDate = dateFormatter.date(from: watchUntilString)
        let createdAtString = json["created_at"].stringValue
        let createdAtDate = dateFormatter.date(from: createdAtString)
        
        //TODO: Refactor with a dictionary or object arg
        let deposit = Deposit(depositID: depositID, ethID: ethId, amountRequested: amountRequested, amountReceived: amountReceived, status: status, watchUntil: watchUntilDate, createdAt: createdAtDate)
        return deposit
    }
    
    func cancelDeposit(depositID: Int, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken,
                                           "DEPOSIT_ID"   : String(depositID)]
        
        let bodyParams: [String: Any] = ["status" : "canceled"]
        
        RequestBuilder.shared.executeRequest(requestType: .cancelDeposit, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
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
}


