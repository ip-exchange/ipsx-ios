//
//  UserDefaults+extensions.swift
//  IPSX
//
//  Created by Cristina Virlan on 09/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

//TODO: change this

public extension UserDefaults {
 
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
}
