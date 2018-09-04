//
//  LegalPersonService.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire

class LegalPersonService {
    
    func submitLegalDetails(companyDetails: Company?, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let countryID = UserManager.shared.getCountryId(countryName: companyDetails?.country) ?? ""

        let body = NSMutableData()
        
        let mimetype = mimeType(for: companyDetails?.certificateURL)
        let urlString = companyDetails?.certificateURL?.absoluteString ?? ""
        let filename = urlString.components(separatedBy: "/").last ?? ""
        
        body.append("\r\n--\(boundary)\r\n".encodedData)
        body.append(contentDisposition.replaceKeysWithValues(paramsDict: ["PARAMETER_NAME" : "incorporation_certificate"]).encodedData)
        body.append("; filename = \"\(filename)\"".encodedData)
        body.append("\r\nContent-Type: \(mimetype)\r\n\r\n".encodedData)
        body.append(companyDetails?.certificateData ?? Data())
        
        apendFormDataString(body: body, name: "name", value: companyDetails?.name)
        apendFormDataString(body: body, name: "address", value: companyDetails?.address)
        apendFormDataString(body: body, name: "registration_number", value: companyDetails?.registrationNumber)
        apendFormDataString(body: body, name: "vat", value: companyDetails?.vat)
        apendFormDataString(body: body, name: "country_id", value: countryID)
        apendFormDataString(body: body, name: "representative_name", value: companyDetails?.representative?.name)
        apendFormDataString(body: body, name: "representative_email", value: companyDetails?.representative?.email)
        apendFormDataString(body: body, name: "representative_phone", value: companyDetails?.representative?.phone)
        

        
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
    
    func uploadCompanyDetails(companyDetails: Company?) {
        
        let countryID = UserManager.shared.getCountryId(countryName: companyDetails?.country) ?? ""
        
        let params: [String: String] = ["name" : companyDetails?.name ?? "",
                                       "address" : companyDetails?.address ?? "",
                                       "registration_number" : companyDetails?.registrationNumber ?? "",
                                       "vat" : companyDetails?.vat ?? "",
                                       "country_id" : countryID,
                                       "representative_name" : companyDetails?.representative?.name ?? "",
                                       "representative_email" : companyDetails?.representative?.email ?? "",
                                       "representative_phone" : companyDetails?.representative?.phone ?? ""]
        
       
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let url = (Url.baseApi + Url.submitLegalArgs).replaceKeysWithValues(paramsDict: urlParams)
        
        upload( multipartFormData: { multipartFormData in
                multipartFormData.append(companyDetails?.certificateData ?? Data(), withName: "incorporation_certificate", fileName: "image.jpeg", mimeType: "image/jpeg")
            
                // Send parameters
                multipartFormData.append((companyDetails?.name ?? "").encodedData, withName: "name")
            
                for (key, value) in params {
                    multipartFormData.append(value.encodedData, withName: key)
                }
        },
            to: url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint("SUCCESS RESPONSE: \(response)")
                    }
                case .failure(let encodingError):
                    print("ERROR RESPONSE: \(encodingError)")
                    
                }
            }
        )
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







