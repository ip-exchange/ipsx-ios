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
    @IBOutlet weak var doneButton: UIButton!
    
    var company: Company?
    var onCollectDataComplete: ((_ company: Company)->())?
    
    private var fieldsStateDic: [String : Bool] = ["company" : false, "email" : false, "phone" : false]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextViews()
        observreFieldsState()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        collectData()
        submitCompanyDetails()
        if let validCompany = self.company {
            self.onCollectDataComplete?(validCompany)
        }

        //TODO (CVI-LegalStuff): Use all that data and make the request before dismiss
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        collectData()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTextViews() {
        //TODO: Add the proper regex when defined by design
        companyRTextField.validationRegex    = RichTextFieldView.validName
        companyRTextField.nextResponderField = emailRtextField.contentTextField
        emailRtextField.validationRegex      = RichTextFieldView.validEmailRegex
        emailRtextField.nextResponderField   = phoneRTextField.contentTextField
        phoneRTextField.validationRegex      = RichTextFieldView.validName
        
        companyRTextField.contentTextField?.text = company?.representative?.name
        emailRtextField.contentTextField?.text = company?.representative?.email
        phoneRTextField.contentTextField?.text = company?.representative?.phone
    }
    
    private func observreFieldsState() {
        self.doneButton.isEnabled = false
        companyRTextField.onFieldStateChange = { state in
            self.fieldsStateDic["company"] = state
            self.doneButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
        emailRtextField.onFieldStateChange = { state in
            self.fieldsStateDic["email"] = state
            self.doneButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
        phoneRTextField.onFieldStateChange = { state in
            self.fieldsStateDic["phone"] = state
            self.doneButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
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
        LegalPersonService().submitLegalDetails(companyDetails: company) { result in
            //self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                
                //TODO: when should we get the new user info details about company ?
                
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true)
                }
                
            case .failure(let error):
                self.handleError(error, requestType: .submitLegalPersonDetails, completion: {
                    self.submitCompanyDetails()
                })
            }
        }
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
