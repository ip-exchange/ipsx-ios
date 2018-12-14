//
//  FundsService.swift
//  IPSX
//
//  Created by Calin Chitu on 11/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class FundsService {

    func createWaccAddress(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let userId      = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId),
            let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
                
                completionHandler(ServiceResult.failure(CustomError.invalidParams))
                return
        }
        let urlParams: [String: String] =  ["USER_ID"      : userId,
                                            "ACCESS_TOKEN" : accessToken]
        
        let request = createRequest(requestType: RequestType.addWaccAddress, urlParams: urlParams)
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
            let address = json["address"]["public_key"]
            completionHandler(ServiceResult.success(address))
        })
    }

    func retrieveWaccAddress(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let userId      = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId),
            let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
                
                completionHandler(ServiceResult.failure(CustomError.invalidParams))
                return
        }
        let urlParams: [String: String] =  ["USER_ID"      : userId,
                                            "ACCESS_TOKEN" : accessToken]
        
        let request = createRequest(requestType: RequestType.getWaccAddress, urlParams: urlParams)
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
            let address = json["address"]["public_key"].stringValue
            
            let dateFormatter = DateFormatter.backendResponseParse()
            let createdDate = dateFormatter.date(from: json["account"]["created_at"].stringValue)

            completionHandler(ServiceResult.success((address, createdDate)))
        })
    }
    
    func getDepositsList(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.getDepositList, urlParams: urlParams)
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
            guard let jsonArray = JSON(data: data).array else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            var deposits: [Deposit] = []
            for json in jsonArray {
                deposits.append(Deposit(json: json))
            }
            completionHandler(ServiceResult.success(deposits))
        })
    }

    func getRefundsList(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.getRefundsList, urlParams: urlParams)
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
            guard let jsonArray = JSON(data: data).array else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            var refunds: [Refund] = []
            for json in jsonArray {
                refunds.append(Refund(json: json))
            }
            completionHandler(ServiceResult.success(refunds))
        })
    }

    func getWithdrawalsList(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.getWithdrawalsList, urlParams: urlParams)
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
            guard let jsonArray = JSON(data: data).array else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            var withdrawals: [Withdrawal] = []
            for json in jsonArray {
                withdrawals.append(Withdrawal(json: json))
            }
            completionHandler(ServiceResult.success(withdrawals))
        })
    }

    func createWithdrawal(ethAddrString: String, amount: Double, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: Any] = ["eth_address"    : ethAddrString,
                                         "amount"         : amount]
        
        let request = createRequest(requestType: RequestType.createWithdraw, urlParams: urlParams, bodyParams: bodyParams)
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
            completionHandler(ServiceResult.success(json))
        })
    }
}
