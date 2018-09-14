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
            self.mapProxyListResponse(jsonArray: jsonArray, completionHandler: completionHandler)
        })
    }
    
    private func mapProxyListResponse(jsonArray: [JSON], completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        var proxies: [Proxy] = []
        
        // TODO (CC): fix this shit and use it by default
        let dateFormatter = DateFormatter.backendResponseParse()
        
        for json in jsonArray {
            
            let proxyID = json["id"].stringValue
            let startDateString = json["start_date"].stringValue
            let endDateString = json["end_date"].stringValue
            let createdDateString = json["created_at"].stringValue
            
            let startDate = dateFormatter.date(from: startDateString)
            let endDate = dateFormatter.date(from: endDateString)
            
            let pacLink = String.generatePacLink(createdDate: createdDateString, proxyId: proxyID)
            
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
            let usedMBString = usage.noDecimalString
            
            let proxyIp = json["ip"].stringValue
            let proxyPort = json["port"].stringValue
            
            let packageID = json["package_id"].intValue
            var proxyPack: ProxyPack?
            if UserManager.shared.testProxyPack?.packId == packageID {
                proxyPack = UserManager.shared.testProxyPack
            }
            else {
                let packs = UserManager.shared.proxyPacks?.filter { return  $0.packId == packageID }
                proxyPack = packs?.first
            }
            let proxyDetails = ProxyActivationDetails(startDate: startDate, endDate: endDate, country: country, userIP: userIp, usedMB: usedMBString, remainingDuration: remainigDuartionString, status: status)
            let proxySetup = ProxySetup(pacLink: pacLink, proxyIP: proxyIp, proxyPort: proxyPort)
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
    
    func createProxy(userIP: String, proxy: Proxy?, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: Any] = ["user_ip"    : userIP,
                                         "country"    : proxy?.proxyDetails?.country ?? "",
                                         "package_id" : proxy?.proxyPack?.packId as Any]
        
        RequestBuilder.shared.executeRequest(requestType: .createProxy, urlParams: urlParams, body: bodyParams, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            guard let jsonDict = JSON(data)["proxy"].dictionary, jsonDict.count > 0 else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
                return
            }
            self.mapCreateProxyResponse(json: jsonDict, completionHandler: completionHandler)
        })
    }
    
    private func mapCreateProxyResponse(json: [String: JSON], completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let dateFormatter = DateFormatter.backendResponseParse()
        
        guard let proxyID       = json["id"]?.stringValue,
            let proxyIP         = json["ip"]?.stringValue,
            let proxyPort       = json["port"]?.stringValue,
            let country         = json["country"]?.stringValue,
            let userIP          = json["user_ip"]?.stringValue,
            let packageID       = json["package_id"]?.intValue,
            let startDateString = json["start_date"]?.stringValue,
            let endDateString   = json["end_date"]?.stringValue,
            let createdString   = json["created_at"]?.stringValue else {
                
            completionHandler(ServiceResult.failure(CustomError.invalidJson))
            return
        }
        
        let startDate = dateFormatter.date(from: startDateString)
        let endDate = dateFormatter.date(from: endDateString)
        let pacLink = String.generatePacLink(createdDate: createdString, proxyId: proxyID)
        
        var proxyPack: ProxyPack?
        if UserManager.shared.testProxyPack?.packId == packageID {
            proxyPack = UserManager.shared.testProxyPack
        }
        else {
            let packs = UserManager.shared.proxyPacks?.filter { return  $0.packId == packageID }
            proxyPack = packs?.first
        }
    
        var remainigDuartionString = "0 min"
        if let eDate = endDate, eDate.timeIntervalSince(Date()) > 0 {
            let remainingDuration = eDate.timeIntervalSince(Date())
            let components = DateFormatter.secondsToDaysHoursMinutes(seconds: Int(remainingDuration))
            remainigDuartionString = DateFormatter.readableDaysHoursMinutes(components:components)
        }
        
        let proxySetup = ProxySetup(pacLink: pacLink, proxyIP: proxyIP, proxyPort: proxyPort)
        let proxyDetails = ProxyActivationDetails(startDate: startDate, endDate: endDate, country: country, userIP: userIP, usedMB: "0", remainingDuration: remainigDuartionString, status: "active")
        let proxy = Proxy(proxyPack: proxyPack, proxyDetails: proxyDetails, proxySetup: proxySetup)
        
        completionHandler(ServiceResult.success(proxy))
    }
    
    func retrieveProxyPackages(testPackage: Bool = false, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let requestType = testPackage ? IPRequestType.retrieveTestProxyPackage : IPRequestType.retrieveProxyPackages
        
        RequestBuilder.shared.executeRequest(requestType: requestType, urlParams: urlParams, completion: { error, data in
            
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
            var packages: [ProxyPack] = []
            for json in jsonArray {
                
                let packId   = json["id"].intValue
                let name     = json["name"].stringValue
                let noOfMB   = json["traffic"].stringValue
                let duration = json["duration"].stringValue
                let price    = json["cost"].stringValue
                
                let package = ProxyPack(packId: packId, name: name, noOfMB: noOfMB, duration: duration, price: price)
                packages.append(package)
            }
            completionHandler(ServiceResult.success(packages))
        })
    }
    
}
