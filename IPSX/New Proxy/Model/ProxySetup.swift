//
//  ProxySetup.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

struct ProxuSetup {
    
    var pacLink: String?
    var proxyIP: String?
    var proxyPort: String?
    
    init(pacLink: String? = nil, proxyIP: String? = nil, proxyPort: String? = nil ) {
        
        self.pacLink = pacLink
        self.proxyIP = proxyIP
        self.proxyPort = proxyPort
    }
}
