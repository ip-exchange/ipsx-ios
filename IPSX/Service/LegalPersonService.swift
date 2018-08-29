//
//  LegalPersonService.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

class LegalPersonService {
    
    func submitLegalDetails(companyDetails: Company?, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let countryID = UserManager.shared.getCountryId(countryName: companyDetails?.country) ?? ""
        
        let bodyDict: [String: String] = [  "name" : companyDetails?.name ?? "",
                                         "address" : companyDetails?.address ?? "",
                                         "registration_number" : companyDetails?.registrationNumber ?? "",
                                         "vat" : companyDetails?.vat ?? "",
                                         "country_id" : countryID,
                                         "representative_name" : companyDetails?.representative?.name ?? "",
                                         "representative_email" : companyDetails?.representative?.email ?? "",
                                         "representative_phone" : companyDetails?.representative?.phone ?? ""
                                         //"incorporation_certificate" : companyDetails?.certificateData ?? ""
                                        ]
        
        let bodyParams = String().generateFormEncodedString(paramsDict: bodyDict)
        
        let urlParams: [String: String] =  ["USER_ID"      : UserManager.shared.userId,
                                            "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        
        RequestBuilder.shared.executeRequest(requestType: .submitLegalPersonDetails, urlParams: urlParams, bodyParams: bodyParams, completion: { error, data in
            
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
}
