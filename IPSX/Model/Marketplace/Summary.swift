//
//  Summary.swift
//  IPSX
//
//  Created by Cristina Virlan on 10/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

class Summary {
    
    let usdSubtotal: Double
    let usdVat: Double
    let usdTotal: Double
    
    let ipsxSubtotal: Double
    let ipsxVat: Double
    let ipsxTotal: Double
    
    init(usdSubtotal: Double, usdVat: Double, usdTotal: Double, ipsxSubtotal: Double, ipsxVat: Double, ipsxTotal: Double) {
        
        self.usdSubtotal = usdSubtotal
        self.usdVat = usdVat
        self.usdTotal = usdTotal
        
        self.ipsxSubtotal = ipsxSubtotal
        self.ipsxVat = ipsxVat
        self.ipsxTotal = ipsxTotal
    }
}

