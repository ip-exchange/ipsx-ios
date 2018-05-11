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
    var email: String
    var password: String
    var proxies: [Proxy]
    var userInfo: UserInfo?
    
    var hasEthAddress: Bool {
        get {
            let noOfEthAddresses = userInfo?.ethAddresses?.count ?? 0
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
    
    private override init() {
        userId = ""
        accessToken = ""
        password = ""
        email = ""
        proxies = []
        super.init()
    }
    
    func storeProxyDetails(proxies: [Proxy]) {
        self.proxies = proxies
    }
    
    func storeEthAddresses(ethAddresses: [EthAddress]) {
        userInfo?.setEthAddresses(ethAddresses: ethAddresses)
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
        proxies = []
        userInfo = nil
    }
    
}
