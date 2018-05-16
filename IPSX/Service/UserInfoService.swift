//
//  UserInfoService.swift
//  IPSX
//
//  Created by Cristina Virlan on 04/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserInfoService {
    
    /// - needs userId and accessToken from Keychain as params for the request
    func retrieveUserInfo(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        guard let userId      = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId),
              let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) else {
                
                completionHandler(ServiceResult.failure(CustomError.invalidParams))
                return
        }
        let params: [String: String] =  ["USER_ID"      : userId,
                                         "ACCESS_TOKEN" : accessToken]
        
        IPRequestManager.shared.executeRequest(requestType: .userInfo, urlParams: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            
            let json = JSON(data: data)
            self.mapResponseAndStoreInfo(json: json, completionHandler: completionHandler)
        })
    }
    
    private func mapResponseAndStoreInfo(json:JSON, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let firstName  = json["first_name"].stringValue
        let middleName = json["middle_name"].stringValue
        let lastName   = json["last_name"].stringValue
        let telegram   = json["telegram"].stringValue
        let countryID  = json["country_id"].stringValue
        let email      = json["email"].stringValue
        let proxyTest  = json["proxy_test"].stringValue
        let ballance   = json["ballance"].intValue
        
        let user = UserInfo(firstName: firstName, middleName: middleName, lastName: lastName, telegram: telegram, countryID: countryID, email: email, proxyTest: proxyTest, ballance: ballance)
        
        //Store User Info
        UserManager.shared.userInfo = user
        
        completionHandler(ServiceResult.success(true))
    }
    
    func retrieveETHaddresses(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let params: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                         "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        IPRequestManager.shared.executeRequest(requestType: .getEthAddress, urlParams: params, completion: { error, data in
            
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
            var ethAddresses: [EthAddress] = []
            for json in jsonArray {
                
                let ethID    = json["id"].stringValue
                let address  = json["address"].stringValue
                let alias    = json["alias"].stringValue
                let verified = json["verified"].intValue
                let status   = json["status"].stringValue
                
                let ethAddress = EthAddress(ethID: ethID, ethAddress: address, ethAlias: alias, ethValidation: verified, ethStatus: status)
                ethAddresses.append(ethAddress)
            }
            completionHandler(ServiceResult.success(ethAddresses))
        })
    }
    
    func getUserCountryList(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        IPRequestManager.shared.executeRequest(requestType: .getUserCountryList, completion: { error, data in
            
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
            var countryList: [[String: String]] = []
            
            for json in jsonArray {
                let countryID   = json["id"].stringValue
                let countryName = json["name"].stringValue
                countryList.append([countryID: countryName])
            }
            completionHandler(ServiceResult.success(countryList))
        })
    }
    
    func updateUserProfile(bodyParams: [String: String], completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        IPRequestManager.shared.executeRequest(requestType: .updateProfile, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
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
    
    func updateETHaddress(requestType: IPRequestType, ethID: String, alias: String = "", address: String = "", completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] =  ["ETH_ID"       : ethID,
                                            "USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: String] = ["address" : address,
                                            "alias"   : alias]
        
        IPRequestManager.shared.executeRequest(requestType: requestType, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
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
