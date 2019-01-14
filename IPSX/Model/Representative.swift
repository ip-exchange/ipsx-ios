//
//  Representative.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class Representative: Equatable {
    
    var name : String
    var email: String
    var phone: String
    
    init(name: String, email: String, phone: String) {
        
        self.name  = name
        self.email = email
        self.phone = phone
    }
    
    static func == (lhs: Representative, rhs: Representative) -> Bool {
        let isEqual =
                lhs.name == rhs.name &&
                lhs.email == rhs.email &&
                lhs.phone == rhs.phone
        return isEqual
    }

}
