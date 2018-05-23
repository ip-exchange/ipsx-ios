//
//  ProxyService.swift
//  IPSX
//
//  Created by Cristina Virlan on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class ProxyService {
    
    func retrieveProxiesForCurrentUser(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let params: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                        "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .retrieveProxies, urlParams: params, completion: { error, data in
            
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
            self.mapResponse(jsonArray: jsonArray, completionHandler: completionHandler)
        })
    }
    
    private func mapResponse(jsonArray: [JSON], completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        var proxies: [Proxy] = []
        
        let dateFormatter = DateFormatter.backendResponseParse()
        
        for json in jsonArray {
            
            //TODO (CVI): PROXY NAME o sa fie updatat later in API (se creeaza model nou pt proxy plans si vor returna un proxyId de unde ne scoatem numele)
            //TODO (CVI): PROXY PRICE in IPSX (with the new model for proxy plans)
            //TODO (CVI): PAC LINK -> trebuie dedus (mai ramane de testat iOS vs Android)
            
            let noOfMB = json["traffic"].stringValue
            let duration = json["duration"].stringValue + " min" //TODO (CVI): format this (min, days, month, etc)
            
            let startDateString = json["start_date"].stringValue
            let endDateString = json["end_date"].stringValue
            
            let startDate = dateFormatter.date(from: startDateString)
            let endDate = dateFormatter.date(from: endDateString)
            
            var remainigDuartionString = "0 min"
            if let eDate = endDate, eDate.timeIntervalSince(Date()) > 0 {
                let remainingDuration = eDate.timeIntervalSince(Date())
                let components = DateFormatter.secondsToDaysHoursMinutes(seconds: Int(remainingDuration))
                remainigDuartionString = DateFormatter.readableDaysHoursMinutes(components:components)
            }
            
            let country = json["country"].stringValue
            let userIp = json["user_ip"].stringValue
            let status = json["status"].stringValue
            let usage = json["usage"].doubleValue
            let noOfMBDouble = json["traffic"].doubleValue
            let usedMBString = (noOfMBDouble - usage).cleanString
            
            let proxyIp = json["ip"].stringValue
            let proxyPort = json["port"].stringValue
            
            let proxyPack = ProxyPack(name: "Silver Pack", noOfMB: noOfMB, duration: duration, price: "TODO")
            let proxyDetails = ProxyActivationDetails(startDate: startDate, endDate: endDate, country: country, userIP: userIp, usedMB: usedMBString, remainingDuration: remainigDuartionString, status: status)
            let proxySetup = ProxySetup(pacLink: "TODO", proxyIP: proxyIp, proxyPort: proxyPort)
            let proxy = Proxy(proxyPack: proxyPack, proxyDetails: proxyDetails, proxySetup: proxySetup)
            proxies.append(proxy)
        }
        completionHandler(ServiceResult.success(proxies))
    }
    
    func getProxyCountryList(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let params: [String: String] = ["ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .getProxyCountryList, urlParams: params, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
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
    
    func requestTokens(ethID: String, amount: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: String] = ["usereth_id"       : ethID,
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
                
                let ethID = json["usereth_id"].stringValue
                let amount = json["amount_requested"].stringValue
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
    
    //TODO (CVI): this should come from the API
    func retrieveTestProxy() -> Proxy {
        
        let testProxyPack = ProxyPack()
        let testProxyActivationDetails = ProxyActivationDetails(usedMB: "0", remainingDuration: "20 min", status: "active".localized)
        let testProxy = Proxy(proxyPack: testProxyPack, proxyDetails: testProxyActivationDetails, isTestProxy: true)
        return testProxy
    }
}
