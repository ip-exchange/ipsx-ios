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
                let components = secondsToDaysHoursMinutes(seconds: Int(remainingDuration))
                remainigDuartionString = readableDaysHoursMinutes(components:components)
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
        UserManager.shared.storeProxyDetails(proxies: proxies)
        completionHandler(ServiceResult.success(proxies))
    }
    
    private func secondsToDaysHoursMinutes (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 3600) / 60)
    }
    
    private func readableDaysHoursMinutes (components: (d: Int, h: Int, m: Int)) -> String {
        var days    = ""
        var hours   = ""
        var minutes = "0 min"
        if components.d > 0 { days    = "\(components.d) d " }
        if components.h > 0 { hours   = "\(components.h) h " }
        if components.m > 0 { minutes = "\(components.m) min" }
        return days+hours+minutes
    }

}
