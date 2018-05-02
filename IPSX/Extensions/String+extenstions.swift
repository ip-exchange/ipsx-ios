//
//  String+extenstions.swift
//  IPSX
//
//  Created by Cristina Virlan on 16/03/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

public extension String {
    
    func removeAllSpaces() -> String {
        return replacingOccurrences(of: " ", with: "")
    }
    
    /// Replace any match of %KEY% in self with coresponding value for same KEY in paramsDic
    
    func replaceKeysWithValues(paramsDict:[String:String], removeAllSpaces: Bool = true) -> String {
        
        var urlWithParams = self
        for param in paramsDict {
            let paramKey   = param.0
            let paramValue = param.1
            urlWithParams  = urlWithParams.replacingOccurrences(of: "%" + paramKey + "%", with: paramValue)
        }
        return removeAllSpaces ? urlWithParams.removeAllSpaces() : urlWithParams
    }
}


