//
//  RepresentativeDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class RepresentativeDetailsController: UIViewController {

    @IBOutlet weak var companyRTextField: RichTextFieldView!
    @IBOutlet weak var emailRtextField: RichTextFieldView!
    @IBOutlet weak var phoneRTextField: RichTextFieldView!
    
    var company: Company?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyRTextField.contentTextField?.text = company?.representative?.name
        emailRtextField.contentTextField?.text = company?.representative?.email
        phoneRTextField.contentTextField?.text = company?.representative?.phone
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        collectData()
        submitCompanyDetails()
        
        //TODO (CVI-LegalStuff): Use all that data and make the request before dismiss
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        collectData()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func collectData() {
        
        let name  = companyRTextField.contentTextField?.text ?? ""
        let email = emailRtextField.contentTextField?.text ?? ""
        let phone = phoneRTextField.contentTextField?.text ?? ""
        
        let representative = Representative(name: name, email: email, phone: phone)
        company?.representative = representative
    }
    
    func submitCompanyDetails() {
        
        //loadingView?.startAnimating()
        LegalPersonService().submitLegalDetails(companyDetails: company, completionHandler: { result in
            //self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                
                //TODO: CVI when should we get the new user info details about company ?
                
                    DispatchQueue.main.async {
                        self.navigationController?.dismiss(animated: true)
                    }
                
            case .failure(let error):
                self.handleError(error, requestType: .submitLegalPersonDetails, completion: {
                    self.submitCompanyDetails()
                })
            }
        })
    }
}

extension RepresentativeDetailsController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                //self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            print("todo - cc")
            //self.errorMessage = "Generic Error Message".localized
        }
    }
}
