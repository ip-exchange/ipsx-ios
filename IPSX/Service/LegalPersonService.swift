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
        
        let countryID = UserManager.shared.getCountryId(countryName: companyDetails?.countryName) ?? ""
        
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
        let filename = companyDetails?.certificateFilename ?? ""
        
        upload( multipartFormData: { multipartFormData in
            
            if let url = companyDetails?.certificateURL {
                do {
                    let documentData = try Data(contentsOf: url)
                    multipartFormData.append(documentData, withName: "incorporation_certificate", fileName: filename, mimeType: mimetype)
                    
                    for (key, value) in params {
                        multipartFormData.append(value.encodedData, withName: key)
                    }
                }
                catch {
                    //TODO
                }
            }
        },
            to: url,
            method: editMode ? .patch : .post,
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
    
    ///
    /// This requires the user countries list to be loaded before
    /// - company call from API returns country ID and we need to map the country name
    ///
    
    func getCompanyDetails(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        if UserManager.shared.userCountries == nil {
            
            UserInfoService().getUserCountryList(completionHandler: { result in
                
                switch result {
                case .success(let countryList):
                    UserManager.shared.userCountries = countryList as? [[String: String]]
                    self.companyDetails(completionHandler: completionHandler)
                    
                case .failure(_):
                    self.companyDetails(completionHandler: completionHandler)
                }
            })
        }
        else {
            companyDetails(completionHandler: completionHandler)
        }
    }
    
    fileprivate func companyDetails(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        RequestBuilder.shared.executeRequest(requestType: .getCompany, urlParams: urlParams, completion: { error, data in
            
            guard error == nil else {
                completionHandler(ServiceResult.failure(error!))
                return
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(CustomError.noData))
                return
            }
            let json = JSON(data: data)
            var company: Company?
            
            if  let name                 = json["name"].string,
                let address              = json["address"].string,
                let registrationNumber   = json["registration_number"].string,
                let vat                  = json["vat"].string,
                let countryId            = json["country_id"].int,
                let representativeName   = json["representative_name"].string,
                let representativeEmail  = json["representative_email"].string,
                let representativePhone  = json["representative_phone"].string,
                let certificate          = json["incorporation_certificate"].string {
                
                let filename = certificate.components(separatedBy: "/").last ?? ""
                let representative = Representative(name: representativeName, email: representativeEmail, phone: representativePhone)
                let countryName = UserManager.shared.getCountryName(countryID: "\(countryId)") ?? ""
                
                company = Company(name: name, address: address, registrationNumber: registrationNumber, vat: vat, countryName: countryName, certificateFilename: filename, representative: representative)
            }
            completionHandler(ServiceResult.success(company as Any))
        })
    }
}







