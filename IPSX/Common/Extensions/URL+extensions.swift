//
//  URL+extensions.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

extension URL {
    
    func valueOf(_ queryParamaterName: String) -> String? {
        
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
