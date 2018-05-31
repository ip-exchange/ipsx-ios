//
//  EnrolTestSummaryController.swift
//  IPSX
//
//  Created by Calin Chitu on 24/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EnrolTestSummaryController: UIViewController {
    
    @IBOutlet weak var loadingView: CustomLoadingView!
    var errorMessage: String? {
        didSet {
            //self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //TODO: for testing
        enrollmentDetails()
    }
    
    func enrollmentDetails() {
        
        loadingView?.startAnimating()
        EnrollmentService().getEnrollmentDetails(requestType: .enrollTestingDetails, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let details):
                if let details = details as? (String, Date) {
                    let ethAddress  = details.0
                    let createdDate = details.1
                    
                    print("TODO (CC): display",ethAddress, createdDate)
                    
                }
                else {
                    self.errorMessage = "Generic Error Message".localized
                }

            case .failure(let error):
                self.handleError(error, requestType: .enrollTesting, completion: {
                    self.enrollmentDetails()
                })
            }
        })
    }
}

extension EnrolTestSummaryController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}
