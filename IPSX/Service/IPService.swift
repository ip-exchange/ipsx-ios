//
//  IPService.swift
//  Test
//
//  Created by Cristina Virlan on 13/02/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import SwiftyJSON

class IPService {
    
    func getPublicIPAddress(completion:@escaping (_ error: Error?, _ ipAddress: String?)->()) {
        
        executeIPRequest(completion: { error, data in
            
            guard error == nil else {
                completion(error, nil)
                return
            }
            guard let data = data else {
                completion(CustomError.noData, nil)
                return
            }
            let json = JSON(data: data)

            if let ipAddress = json["ip"].string {
                completion(nil, ipAddress)
            }
            else {
                completion(CustomError.invalidJson, nil)
            }
        })
    }
    
    func getCountryList(completion:@escaping (_ error: Error?, _ countryList: [String]?)->()) {
        
        let params: [String: String] = ["action": "cclist"]
        
        executeProxyRequest(requestType: .getCountryList, params: params, completion: { error, data in
            
            guard error == nil else {
                completion(error, nil)
                return
            }
            guard let data = data else {
                completion(CustomError.noData, nil)
                return
            }
            let json = JSON(data: data)
            
            if let countryArray = json.arrayObject as? [String] {
                completion(nil, countryArray)
            }
            else {
                completion(CustomError.invalidJson, nil)
            }
        })
    }
    
    func getProxy(forParams request: ProxyRequest, completion:@escaping (_ error: Error?, _ port: String)->()) {
        
        let params: [String: String] = ["action"       : request.action,
                                        "country"      : request.country,
                                        "app_uid"      : request.appUid,
                                        "proxy_ttl"    : request.proxyTTL,
                                        "proxy_traffic": request.proxyTraffic,
                                        "auth_ip"      : request.authIP]
        
        executeProxyRequest(requestType: .getProxy, params: params, completion: { error, data in
            
            guard error == nil else {
                completion(error, "")
                return
            }
            guard let data = data else {
                completion(CustomError.noData, "")
                return
            }
            
            let json = JSON(data: data)
            let port = json["port"].stringValue
            let status = json["status"].stringValue
            
            if !status.contains("success") {
                completion(CustomError.notSuccessful, "")
            }
            else if port != "" {
                completion(nil, port)
            }
            else {
                completion(CustomError.invalidJson, "")
            }
        })
    }
    
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    func getPrivateWifiAddress(completion:@escaping (_ address: String?)->()) {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { completion(nil); return }
        guard let firstAddr = ifaddr else { completion(nil); return }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        completion(address)
    }
}
extension IPService: IPRetrievable {}
extension IPService: IPRequestCapable {}