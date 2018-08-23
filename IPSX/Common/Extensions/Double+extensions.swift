//
//  Double+extensions.swift
//  IPSX
//
//  Created by Cristina Virlan on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

extension Double {
    
    var noDecimalString: String {
        return String(format: "%.0f", self) 
    }
    
    var twoDecimalsString: String {
        return String(format: "%.2f", self)
    }
    
    var cleanString: String {
        
        if floor(self) == self {
            return self.noDecimalString
        }
        else {
            return self.twoDecimalsString
        }
    }
}
