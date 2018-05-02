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
    
    private override init() {
        userId = ""
        accessToken = ""
        proxies = []
        super.init()
    }
    
    var userId: String
    var accessToken: String
    var proxies: [Proxy]
    
    func storeUserInfo(userId: String? = nil, accessToken: String? = nil) {
        
        if let userId = userId {
            KeychainWrapper.setString(value: userId, forKey: KeychainKeys.userId)
            UserManager.shared.userId = userId
        }
        if let accessToken = accessToken {
            KeychainWrapper.setString(value: accessToken, forKey: KeychainKeys.accessToken)
            UserManager.shared.accessToken = accessToken
        }
    }
    
    func storeProxyDetails(proxies: [Proxy]) {
        UserManager.shared.proxies = proxies
    }
        
    func retrieveUserInfo() {
        
        if let userId = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId) {
            UserManager.shared.userId = userId
        }
        if let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) {
            UserManager.shared.accessToken = accessToken
        }
    }
    
    func removeUserInfo() {
        
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.userId)
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.accessToken)
    }
    
    func isLoggedIn() -> Bool {
        
        return false
    }
}
