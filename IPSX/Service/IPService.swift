//
//  IPService.swift
//  Test
//
//  Created by Cristina Virlan on 13/02/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class IPService {
    
    func getPublicIPAddress(completion:@escaping (_ error: Error?, _ ipAddress: String?)->()) {
        
        executeIPRequest(completion: { error, data in
            
            guard error == nil else {
                completion(error, nil)
                return
            }
            guard let data = data else {
                completion(RequestError.noData, nil)
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
