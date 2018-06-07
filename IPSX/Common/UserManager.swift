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
    var facebookToken: String = ""
    var email: String = ""
    var password: String = ""
    var userInfo: UserInfo?
    var tokenRequests: [TokenRequest]?
    var ethAddresses: [EthAddress]?
    var proxies: [Proxy]?
    var userCountries: [[String: String]]?
    var proxyCountries: [String]?
    var options: Options?
    
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
    
    var isLoggedInWithFB: Bool {
        get {
            if isLoggedIn && email == "" && password == "" {
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
    
    func storeAccessDetails(userId: String, accessToken: String, email: String = "", password: String = "", facebookToken: String = "") {
        
        KeychainWrapper.setString(value: userId, forKey: KeychainKeys.userId)
        KeychainWrapper.setString(value: accessToken, forKey: KeychainKeys.accessToken)
        KeychainWrapper.setString(value: email, forKey: KeychainKeys.email)
        KeychainWrapper.setString(value: password, forKey: KeychainKeys.password)
        KeychainWrapper.setString(value: facebookToken, forKey: KeychainKeys.facebookToken)
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
        if let facebookToken = KeychainWrapper.stringForKey(keyName: KeychainKeys.facebookToken) {
            UserManager.shared.facebookToken = facebookToken
        }
    }
    
    func removeUserDetails() {
        
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.userId)
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.accessToken)
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.email)
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.password)
        let _ = KeychainWrapper.removeObjectForKey(keyName: KeychainKeys.facebookToken)
        
        userId = ""
        accessToken = ""
        facebookToken = ""
        email = ""
        password = ""
        proxies = nil
        tokenRequests = nil
        userCountries = nil
        ethAddresses = nil
        proxyCountries = nil
        userInfo = nil
    }
    
    func getUserCountryList() -> [String] {
        
        var countryArray: [String] = []
        if let countries = UserManager.shared.userCountries {
            for country in countries {
                if let key = country.keys.first, let countryName = country[key] {
                    countryArray.append(countryName)
                }
            }
        }
        return countryArray
    }
    
    func getCountryId(countryName: String?) -> String? {
        
        var countryID: String?
        if let countries = UserManager.shared.userCountries {
            for country in countries {
                if let key = country.keys.first, let value = country[key], value == countryName {
                    countryID = key
                }
            }
        }
        return countryID
    }
    
    func getCountryName(countryID: String?) -> String? {
        
        var countryName: String?
        if let countries = UserManager.shared.userCountries {
            for country in countries {
                if let key = country.keys.first, let value = country[key], key == countryID {
                    countryName = value
                }
            }
        }
        return countryName
    }
    
    func logout() {
        removeUserDetails()
    }
}
