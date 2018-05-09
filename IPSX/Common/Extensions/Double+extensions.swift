//
//  Double+extensions.swift
//  IPSX
//
//  Created by Cristina Virlan on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

extension Double {
    var cleanString: String {
        return String(format: "%.0f", self) 
    }
}
