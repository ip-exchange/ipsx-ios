//
//  RepresentativeDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class RepresentativeDetailsController: UIViewController {

    @IBOutlet weak var companyRTextField: RichTextFieldView!
    @IBOutlet weak var emailRtextField: RichTextFieldView!
    @IBOutlet weak var phoneRTextField: RichTextFieldView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var signWithAnotherAccount: UIButton!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }

    var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }

    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var company: Company?
    var editMode = false
    var nonDismissable = true
    var lastStepForLegalRegistration = true
    var onCollectDataComplete: ((_ company: Company?)->())?
    var firstLoginFlow = false

    private var fieldsStateDic: [String : Bool] = ["repName" : false, "repEmail" : false, "repPhone" : false]

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTextViews()
        observreFieldsState()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.doneButton.isEnabled = self.canContinue()
    }

    @IBAction func doneButtonAction(_ sender: Any) {
        
        collectData()
        if lastStepForLegalRegistration {
            submitCompanyDetails()
        }
        /*
             Edit User Profile: add company when upgrading from Individual to Legal / edit existing company details
             Pass company details on completion for later submit
         */
        else {
            self.company?.status = .collected
            self.onCollectDataComplete?(self.company)
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        collectData()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signWithAnotherAccount(_ sender: Any) {
        UserManager.shared.logout()
        self.performSegue(withIdentifier: "UnwindAndShowLandingID", sender: nil)
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
        
        fieldsStateDic["repName"] = company?.representative?.name != nil
        fieldsStateDic["repEmail"] = company?.representative?.email != nil
        fieldsStateDic["repPhone"] = company?.representative?.phone != nil
    }
    
    private func observreFieldsState() {
        
        self.doneButton.isEnabled = false
        companyRTextField.onFieldStateChange = { state in
            self.fieldsStateDic["repName"] = state
            self.doneButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
        emailRtextField.onFieldStateChange = { state in
            self.fieldsStateDic["repEmail"] = state
            self.doneButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
        phoneRTextField.onFieldStateChange = { state in
            self.fieldsStateDic["repPhone"] = state
            self.doneButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
    }

    private func canContinue() -> Bool {
        return !self.fieldsStateDic.values.contains(false)
    }
    
    private func collectData() {
        
        let name  = companyRTextField.contentTextField?.text ?? ""
        let email = emailRtextField.contentTextField?.text ?? ""
        let phone = phoneRTextField.contentTextField?.text ?? ""
        
        let representative = Representative(name: name, email: email, phone: phone)
        company?.representative = representative
    }
    
    func submitCompanyDetails() {
        
        loadingView?.startAnimating()
        LegalPersonService().submitLegalDetails(companyDetails: company, editMode: editMode) { result in
            self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    if self.firstLoginFlow {
                        self.performSegue(withIdentifier: "CongratsSegueID", sender: nil)
                    } else {
                        self.navigationController?.dismiss(animated: true)
                    }
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.submitLegalPersonDetails, completion: {
                    self.submitCompanyDetails()
                })
            }
        }
    }
}

extension RepresentativeDetailsController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension RepresentativeDetailsController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
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
