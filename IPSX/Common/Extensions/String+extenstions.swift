//
//  String+extenstions.swift
//  IPSX
//
//  Created by Cristina Virlan on 16/03/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

public extension String {
    
    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }
    
    var encodedData: Data {
        return self.data(using: String.Encoding.utf8) ?? Data()
    }
    
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

    func trimLeadingAndTrailingSpaces() -> String {
        
        let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString
    }
    
    ///  PAC file naming convention: base_url/order/proxy/pac/1361527085819.pac?type=ios
    ///  1361527085819 = {id_proxy}{timestamp_created_at}
    static func generatePacLink(createdDate: String, proxyId: String) -> String {
        
        let dateFormatter = DateFormatter.backendResponseParse()
        let date = dateFormatter.date(from: createdDate)
        
        guard let timestamp = date?.timeIntervalSince1970 else {
            return ""
        }
        return Url.pacBaseUrl + proxyId + "\(Int(timestamp))" + ".pac?type=ios"
    }
    
    func removeCharacters(characters: String) -> String {
        
        let characterSet = NSCharacterSet(charactersIn: characters)
        let components = self.components(separatedBy: characterSet as CharacterSet)
        let result = components.joined(separator: "")
        return result
    }
    
    func dateObject(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        
        let dateFormatter = DateFormatter.backendResponseParse(format: format)
        return dateFormatter.date(from: self)
    }
    
    func daysHoursMinutesFormated() -> String {
        var formatedDuration = self + " min"
        if let intDuration = Int(self) {
            let components = DateFormatter.secondsToDaysHoursMinutes(seconds: Int(intDuration * 60))
            formatedDuration = DateFormatter.readableDaysHoursMinutes(components:components)
        }
        return formatedDuration
    }
    
}


