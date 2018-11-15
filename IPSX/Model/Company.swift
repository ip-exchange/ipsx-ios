//
//  Company.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class Company {
    
    enum CompanyStatus: String {
        
        case pending    = "pending"
        case rejected   = "rejected"
        case verified   = "verified"
        case incomplete = "incomplete"
        case collected  = "collected"
        case unknown    = "unknown"
    }

    var name: String
    var address: String
    var registrationNumber: String
    var vat: String
    var countryName: String
    var certificateFilename: String?
    var certificateURL: URL?
    var representative: Representative?
    var status: CompanyStatus

    init(name: String, address: String, registrationNumber: String, vat: String, countryName: String, certificateFilename: String, representative: Representative? = nil, statusString: String = "") {
        
        self.name = name
        self.status = CompanyStatus(rawValue: statusString) ?? .unknown
        self.address = address
        self.registrationNumber = registrationNumber
        self.vat = vat
        self.countryName = countryName
        self.certificateFilename = certificateFilename
        self.representative = representative
    }
    
    init() {
        
        self.name = ""
        self.status = .unknown
        self.address = ""
        self.registrationNumber = ""
        self.vat = ""
        self.countryName = ""
        self.certificateFilename = nil
        self.certificateURL = nil
        self.representative = nil
    }
}
