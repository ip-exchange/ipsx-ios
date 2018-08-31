//
//  Company.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class Company {
    
    var name: String
    var address: String
    var registrationNumber: String
    var vat: String
    var country: String
    var certificateData: Data?
    var certificateURL: URL?
    var representative: Representative?
    
    init(name: String, address: String, registrationNumber: String, vat: String, country: String, certificateData: Data?, representative: Representative? = nil) {
        
        self.name = name
        self.address = address
        self.registrationNumber = registrationNumber
        self.vat = vat
        self.country = country
        self.certificateData = certificateData
        self.representative = representative
    }
    
    init() {
        
        self.name = ""
        self.address = ""
        self.registrationNumber = ""
        self.vat = ""
        self.country = ""
        self.certificateData = Data()
        self.representative = nil
        self.certificateURL = nil
    }
}
