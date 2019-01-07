//
//  CompanyDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import MobileCoreServices

class CompanyDetailsController: UIViewController {
    
    @IBOutlet weak var nameRTextField: RichTextFieldView!
    @IBOutlet weak var addressRTextField: RichTextFieldView!
    @IBOutlet weak var regNumberRTextField: RichTextFieldView!
    @IBOutlet weak var vatRTextField: RichTextFieldView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var signWithAnotherAccount: UIButton!

    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }

    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var nonDismissable = true
    var firstLoginFlow = false

     private var fieldsStateDic: [String : Bool] = ["name" : false, "address" : false, "regNum" : false, "vat" : false]

    var company: Company? 
    var onCollectDataComplete: ((_ company: Company?)->())?
    var editMode = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTextViews()
        observreFieldsState()
        
        if editMode {
            prePopulate()
        }
        if company == nil {
            company = Company()
        }
        closeButton.isHidden = nonDismissable
        signWithAnotherAccount.isHidden = !nonDismissable
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.nextButton.isEnabled = self.canContinue()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CompanyDetailsSegueID", let certController = segue.destination as? CountryAndCertificateController {
            collectData()
            certController.company = company
            certController.nonDismissable = nonDismissable
            certController.firstLoginFlow = firstLoginFlow
            certController.editMode = editMode
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        self.view.endEditing(true)
        DispatchQueue.main.async { self.performSegue(withIdentifier: "CompanyDetailsSegueID", sender: nil) }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func signWithAnotherAccount(_ sender: Any) {
        UserManager.shared.logout()
        DispatchQueue.main.async { self.performSegue(withIdentifier: "UnwindAndShowLandingID", sender: nil) }
    }

    private func setupTextViews() {
        //TODO: Add the proper regex when defined by design
        nameRTextField.validationRegex           = RichTextFieldView.validName
        nameRTextField.limitLenght               = 30
        nameRTextField.nextResponderField        = addressRTextField.contentTextField
        addressRTextField.validationRegex        = RichTextFieldView.validName
        addressRTextField.nextResponderField     = regNumberRTextField.contentTextField
        regNumberRTextField.validationRegex      = RichTextFieldView.validName
        regNumberRTextField.nextResponderField   = vatRTextField.contentTextField
        vatRTextField.validationRegex            = RichTextFieldView.validName
    }
    
    private func observreFieldsState() {
        self.nextButton.isEnabled = false
        nameRTextField.onFieldStateChange = { state in
            self.fieldsStateDic["name"] = state
            self.nextButton.isEnabled = self.canContinue()
        }
        addressRTextField.onFieldStateChange = { state in
            self.fieldsStateDic["address"] = state
            self.nextButton.isEnabled = self.canContinue()
        }
        regNumberRTextField.onFieldStateChange = { state in
            self.fieldsStateDic["regNum"] = state
            self.nextButton.isEnabled = self.canContinue()
        }
        vatRTextField.onFieldStateChange = { state in
            self.fieldsStateDic["vat"] = state
            self.nextButton.isEnabled = self.canContinue()
        }
    }
    
    private func canContinue() -> Bool {
        return !self.fieldsStateDic.values.contains(false)
    }
    
    private func collectData() {
        
        company?.name = nameRTextField.contentTextField?.text ?? ""
        company?.address = addressRTextField.contentTextField?.text ?? ""
        company?.registrationNumber = regNumberRTextField.contentTextField?.text ?? ""
        company?.vat = vatRTextField.contentTextField?.text ?? ""
    }
    
    private func prePopulate() {
        guard company != nil else { return }
        
        self.fieldsStateDic["name"] = company?.name != nil
        self.fieldsStateDic["address"] = company?.address != nil
        self.fieldsStateDic["regNum"] = company?.registrationNumber != nil
        self.fieldsStateDic["vat"] = company?.vat != nil
        
        nameRTextField.contentTextField?.text = company?.name ?? ""
        addressRTextField.contentTextField?.text = company?.address ?? ""
        regNumberRTextField.contentTextField?.text = company?.registrationNumber ?? ""
        vatRTextField.contentTextField?.text = company?.vat ?? ""
    }
    
    private func updateUI() {
        
        self.nextButton.isEnabled = self.canContinue()
    }

    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard view.frame.size.height <= 568 else { return }

        titleLabelTopConstraint.constant = -30
        stackHeightConstraint.constant   = 270
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        
        guard view.frame.size.height <= 568 else { return }

        titleLabelTopConstraint.constant = 26
        stackHeightConstraint.constant   = 320
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension CompanyDetailsController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

