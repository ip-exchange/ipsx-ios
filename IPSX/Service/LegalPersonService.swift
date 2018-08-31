//
//  LegalPersonService.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import MobileCoreServices

class LegalPersonService {
    
    func submitLegalDetails(companyDetails: Company?, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let countryID = UserManager.shared.getCountryId(countryName: companyDetails?.country) ?? ""

        let body = NSMutableData()
        apendFormDataString(body: body, name: "name", value: companyDetails?.name)
        apendFormDataString(body: body, name: "address", value: companyDetails?.address)
        apendFormDataString(body: body, name: "registration_number", value: companyDetails?.registrationNumber)
        apendFormDataString(body: body, name: "vat", value: companyDetails?.vat)
        apendFormDataString(body: body, name: "country_id", value: countryID)
        apendFormDataString(body: body, name: "representative_name", value: companyDetails?.representative?.name)
        apendFormDataString(body: body, name: "representative_email", value: companyDetails?.representative?.email)
        apendFormDataString(body: body, name: "representative_phone", value: companyDetails?.representative?.phone)
        
        let mimetype = mimeType(for: companyDetails?.certificateURL)
        let filename = companyDetails?.certificateURL?.absoluteString ?? ""
            
        body.append("\r\n--\(boundary)\r\n".encodedData)
        body.append(contentDisposition.replaceKeysWithValues(paramsDict: ["PARAMETER_NAME" : "incorporation_certificate"]).encodedData)
        body.append("; filename = \"\(filename)\"".encodedData)
        body.append("\r\n Content-Type: \(mimetype)\r\n\r\n".encodedData)

        body.append("\r\n--\(boundary)--\r\n".encodedData)
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .submitLegalPersonDetails, urlParams: urlParams, body: body, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard data != nil else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func apendFormDataString(body: NSMutableData, name: String, value: String?)  {
        
        body.append("\r\n--\(boundary)\r\n".encodedData)
        body.append((contentDisposition.replaceKeysWithValues(paramsDict: ["PARAMETER_NAME" : name]) + "\r\n\r\n").encodedData)
        body.append((value ?? "" + "\r\n").encodedData)
    }
    
    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires `import MobileCoreServices`.
    ///
    /// - parameter path: The path of the file for which we are going to determine the mime type.
    ///
    /// - returns: Returns the mime type if successful. Returns `application/octet-stream` if unable to determine mime type.
    
    private func mimeType(for url: URL?) -> String {
        
        if let pathExtension = url?.pathExtension,
           let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}







