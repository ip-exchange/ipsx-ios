//
//  ProxySetup.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

struct ProxySetup {
    
    var pacLink: String
    var proxyIP: String
    var proxyPort: String
    
    init(pacLink: String = "", proxyIP: String = "", proxyPort: String = "" ) {
        
        self.pacLink   = pacLink != "" ? pacLink : "N/A"
        self.proxyIP   = proxyIP != "" ? proxyIP : "N/A"
        self.proxyPort = proxyPort != "" ? proxyPort : "N/A"
    }
}
