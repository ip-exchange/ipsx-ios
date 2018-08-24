//
//  Company.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

struct Company {
    
    var name: String
    var address: String
    var registrationNumber: String
    var vat: String
    var country: String
    var certificateData: Data
    var representative: Representative
    
    init(name: String, address: String, registrationNumber: String, vat: String, country: String, certificateData: Data, representative: Representative) {
        
        self.name = name
        self.address = address
        self.registrationNumber = registrationNumber
        self.vat = vat
        self.country = country
        self.representative = representative
        self.certificateData = certificateData
    }
}
