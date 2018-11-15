//
//  UserDefaults+extensions.swift
//  IPSX
//
//  Created by Cristina Virlan on 09/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

public extension UserDefaults {
 
    public enum UserDefaultsKey: String {
        
        case defaultETHAddressID   = "DEFAULT_ETH_ADDRESS_KEY"
        case freshInstallID = "DEFAULT_FRESH_INSTALL_KEY"
        case marketTutorialChekced = "MARKET_TUTORIAL_CHECKED"
   }
    
    func storeDelfaultETHAddressID(ethAddressID: Int?) {
        UserDefaults.standard.set(ethAddressID, forKey: UserDefaultsKey.defaultETHAddressID.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func loadDelfaultETHAddressID() -> Int? {
        return UserDefaults.standard.integer(forKey: UserDefaultsKey.defaultETHAddressID.rawValue)
    }
    
    func marketTutorialChecked() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKey.marketTutorialChekced.rawValue)
    }
    
    func setMarketTutorialChecked(_ state: Bool) {
        UserDefaults.standard.set(state, forKey: UserDefaultsKey.marketTutorialChekced.rawValue)
        UserDefaults.standard.synchronize()
    }

    func isFreshInstall() -> Bool {
        let isFreshInstall = !UserDefaults.standard.bool(forKey: UserDefaultsKey.freshInstallID.rawValue)
        UserDefaults.standard.set(true, forKey:  UserDefaultsKey.freshInstallID.rawValue)
        UserDefaults.standard.synchronize()
        return isFreshInstall
    }

}
