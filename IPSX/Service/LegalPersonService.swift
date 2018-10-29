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
import IPSXNetworkingFramework

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
                }
                catch {
                    completionHandler(ServiceResult.failure(CustomError.notSuccessful))
                }
            }
            for (key, value) in params {
                multipartFormData.append(value.encodedData, withName: key)
            }
        },
            to: url,
            method: editMode ? .patch : .post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    
                case .success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        if response.response?.statusCode == 200 {
                            completionHandler(ServiceResult.success(true))
                        }
                        else {
                            completionHandler(ServiceResult.failure(CustomError.notSuccessful))
                        }
                    }
                    
                case .failure(let encodingError):
                    completionHandler(ServiceResult.failure(encodingError))
                }
            }
        )
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
        
        let request = createRequest(requestType: RequestType.getCompany, urlParams: urlParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            let json = JSON(data: data)
            let jsonCompany = json["company"]
            
            var company: Company?
            
            if  let name                 = jsonCompany["name"].string,
                let address              = jsonCompany["address"].string,
                let registrationNumber   = jsonCompany["registration_number"].string,
                let vat                  = jsonCompany["vat"].string,
                let countryId            = jsonCompany["country_id"].int,
                let representativeName   = jsonCompany["representative_name"].string,
                let representativeEmail  = jsonCompany["representative_email"].string,
                let representativePhone  = jsonCompany["representative_phone"].string,
                let certificate          = jsonCompany["incorporation_certificate"].string,
                let companyStatusString  = jsonCompany["status"].string {
                
                let filename = certificate.components(separatedBy: "/").last ?? ""
                let representative = Representative(name: representativeName, email: representativeEmail, phone: representativePhone)
                let countryName = UserManager.shared.getCountryName(countryID: "\(countryId)") ?? ""
                
                company = Company(name: name, address: address, registrationNumber: registrationNumber, vat: vat, countryName: countryName, certificateFilename: filename, representative: representative, statusString: companyStatusString)
            }
            completionHandler(ServiceResult.success(company as Any))
        })
    }
}







