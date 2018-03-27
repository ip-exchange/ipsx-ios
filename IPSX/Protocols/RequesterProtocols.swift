//
//  RequesterProtocols.swift
//  IPSX
//
//  Created by Cristina Virlan on 15/03/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

public protocol IPRequestCapable {
    func executeProxyRequest(requestType:IPRequestType, params: [String: Any], completion:@escaping (Error?, Data?)->Void)
}

extension IPRequestCapable {
    
    func executeProxyRequest(requestType:IPRequestType, params: [String: Any] = [:], completion:@escaping (Error?, Data?)->Void) {
        
        let requestManager = IPRequestManager.shared
        if let request = requestManager.createRequest(requestType: requestType, params: params) {
            
            requestManager.session.dataTask(with: request , completionHandler: { data, response, error in
                
                if let error = error {
                    completion(error, data)
                }
                else if let httpResponse = response as? HTTPURLResponse , let data = data {
                    
                    let statusCode = httpResponse.statusCode
                    switch statusCode {
                        
                    case 200:
                        print(NSDate(),"\(type(of: self)):\(#function) Request succeeded")
                        completion(nil, data)
                        
                    default:
                        print(NSDate(), "\(type(of: self)):\(#function) Request failed with status code: ", statusCode)
                        completion(CustomError.statusCodeNOK(statusCode), data)
                    }
                }
            }).resume()
            
        }
    }
}
