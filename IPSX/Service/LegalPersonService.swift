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
        
    func submitLegalDetails(companyDetails: Company?, editMode: Bool = false, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
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
        let mimetype = mimeType(for: companyDetails?.certificateURL)
        let urlString = companyDetails?.certificateURL?.absoluteString ?? ""
        let filename = urlString.components(separatedBy: "/").last ?? ""
        
        upload( multipartFormData: { multipartFormData in
                multipartFormData.append(companyDetails?.certificateData ?? Data(), withName: "incorporation_certificate", fileName: filename, mimeType: mimetype)
            
                for (key, value) in params {
                    multipartFormData.append(value.encodedData, withName: key)
                }
        },
            to: url,
            method: editMode ? .put : .post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        print("SUCCESS RESPONSE: \(response)")
                        completionHandler(ServiceResult.success(true))
                    }
                    
                case .failure(let encodingError):
                    completionHandler(ServiceResult.failure(encodingError))
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







