//
//  ProxyManager.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

public class ProxyManager: NSObject {
    
    public static var shared = ProxyManager()
    private override init() {}
    
    var allOffers: [Offer]?
    var cart: Cart?
    var proxyCountries: [String]?

}
