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
    private override init() {}
    
    var userId: String = ""
    var accessToken: String = ""
    var email: String = ""
    var password: String = ""
    var userInfo: UserInfo?
    var tokenRequests: [TokenRequest]?
    var ethAddresses: [EthAddress]?
    var proxies: [Proxy]?
    var userCountries: [[String: String]]?
    var proxyCountries: [String]?
    
    var hasEthAddress: Bool {
        get {
            let noOfEthAddresses = ethAddresses?.count ?? 0
            return noOfEthAddresses > 0
        }
    }
    
    var isLoggedIn: Bool {
        get {
            if userId != "" && accessToken != "" {
                return true
            }
            return false
        }
    }
    
    var hasTestProxyAvailable: Bool {
        get {
            return UserManager.shared.userInfo?.proxyTest == ""
        }
    }
    
    func storeAccessDetails(userId: String, accessToken: String, email: String, password: String) {
        
        KeychainWrapper.setString(value: userId, forKey: KeychainKeys.userId)
        KeychainWrapper.setString(value: accessToken, forKey: KeychainKeys.accessToken)
        KeychainWrapper.setString(value: email, forKey: KeychainKeys.email)
        KeychainWrapper.setString(value: password, forKey: KeychainKeys.password)
        retrieveAccessDetails()
    }
        
    func retrieveAccessDetails() {
        
        if let userId = KeychainWrapper.stringForKey(keyName: KeychainKeys.userId) {
            UserManager.shared.userId = userId
        }
        if let accessToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.accessToken) {
            UserManager.shared.accessToken = accessToken
        }
        if let email = KeychainWrapper.stringForKey(keyName: KeychainKeys.email) {
            UserManager.shared.email = email
        }
        if let password = KeychainWrapper.stringForKey(keyName: KeychainKeys.password) {
            UserManager.shared.password = password
        }
    }
    
    func removeUserDetails() {
        
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.userId)
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.accessToken)
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.email)
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.password)
        
        userId = ""
        accessToken = ""
        email = ""
        password = ""
        proxies = nil
        tokenRequests = nil
        userCountries = nil
        ethAddresses = nil
        proxyCountries = nil
        userInfo = nil
    }
}
