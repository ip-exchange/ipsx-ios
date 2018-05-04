//
//  UserManager.swift
//  IPSX
//
//  Created by Cristina Virlan on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

public class UserManager: NSObject {

    public static var shared = UserManager()
    
    var userId: String
    var accessToken: String
    var proxies: [Proxy]
    var userInfo: UserInfo?
    
    private override init() {
        userId = ""
        accessToken = ""
        proxies = []
        super.init()
    }
    
    func storeProxyDetails(proxies: [Proxy]) {
        self.proxies = proxies
    }
    
    func storeAccessDetails(userId: String, accessToken: String) {
        
        KeychainWrapper.setString(value: userId, forKey: KeychainKeys.userId)
        KeychainWrapper.setString(value: accessToken, forKey: KeychainKeys.accessToken)
    }
        
    func retrieveAccessDetails() {
        
        if let userId = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId) {
            UserManager.shared.userId = userId
        }
        if let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) {
            UserManager.shared.accessToken = accessToken
        }
    }
    
    func removeAccessDetails() {
        
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.userId)
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.accessToken)
    }
    
    func isLoggedIn() -> Bool {
        
        if userId != "" && accessToken != "" {
            return true
        }
        return false
    }
}
