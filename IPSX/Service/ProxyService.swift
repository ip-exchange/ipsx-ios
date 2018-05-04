//
//  ProxyService.swift
//  IPSX
//
//  Created by Cristina Virlan on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProxyService {
    
    func retrieveProxiesForCurrentUser(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let params: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                        "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        IPRequestManager.shared.executeRequest(requestType: .retrieveProxies, params: params, completion: { error, data in
            
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for json in jsonArray {
            
            //TODO (CVI): proxy name o sa fie updatat later in API (se creeaza model nou pt proxy plans si vor returna un proxyId de unde ne scoatem numele)
            //TODO (CVI): remainingDuration trebuie calculat sau ne rugam sa ni-l puna in raspuns
            //TODO (CVI): nu avem pac link returnat de API
            
            let noOfMB = json["traffic"].stringValue
            let duration = json["duration"].stringValue + " min" //TODO (CVI): format this (min, days, month, etc)
            
            let startDate = json["start_date"].stringValue
            let endDate = json["end_date"].stringValue
            let country = json["country"].stringValue
            let userIp = json["user_ip"].stringValue
            let status = json["status"].stringValue
            let usage = json["usage"].doubleValue
            let noOfMBDouble = json["traffic"].doubleValue
            let remainingMBString = (noOfMBDouble - usage).cleanString
            
            let proxyIp = json["ip"].stringValue
            let proxyPort = json["port"].stringValue
            
            let proxyPack = ProxyPack(name: "Silver Pack", noOfMB: noOfMB, duration: duration)
            let proxyDetails = ProxyActivationDetails(startDate: dateFormatter.date(from: startDate), endDate: dateFormatter.date(from: endDate), country: country, userIP: userIp, remainingMB: remainingMBString, remainingDuration: "20 min", status: status)
            let proxySetup = ProxySetup(pacLink: "TODO", proxyIP: proxyIp, proxyPort: proxyPort)
            let proxy = Proxy(proxyPack: proxyPack, proxyDetails: proxyDetails, proxySetup: proxySetup)
            proxies.append(proxy)
        }
        UserManager.shared.storeProxyDetails(proxies: proxies)
        completionHandler(ServiceResult.success(proxies))
    }
}
