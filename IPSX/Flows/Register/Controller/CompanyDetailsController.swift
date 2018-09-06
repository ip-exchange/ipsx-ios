//
//  CompanyDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import MobileCoreServices

class CompanyDetailsController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var nameRTextField: RichTextFieldView!
    @IBOutlet weak var addressRTextField: RichTextFieldView!
    @IBOutlet weak var regNumberRTextField: RichTextFieldView!
    @IBOutlet weak var vatRTextField: RichTextFieldView!
    @IBOutlet weak var countryRTextField: RichTextFieldView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var choosenFileLabel: UILabel!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    private var searchController: SearchViewController?
    private var representativeController: RepresentativeDetailsController?
    private var fieldsStateDic: [String : Bool] = ["name" : false, "address" : false, "regNum" : false, "vat" : false]

    var company: Company? = Company()
    var onCollectDataComplete: ((_ company: Company?)->())?
    var editMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextViews()
        observreFieldsState()
        if company != nil {
            editMode = true
            company = Company()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)

        if let representative = representativeController?.company?.representative {
            company?.representative = representative
        }
        if UserManager.shared.userCountries == nil {
            
            UserInfoService().getUserCountryList(completionHandler: { result in
                
                switch result {
                case .success(let countryList):
                    UserManager.shared.userCountries = countryList as? [[String: String]]
                    DispatchQueue.main.async { self.updateFields() }
                    
                case .failure(_): break
                }
            })
        } else {
            self.updateFields()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "NextSegueID", let repController = segue.destination as? RepresentativeDetailsController {
            representativeController = repController
            collectData()
            repController.company = company
            repController.editMode = editMode
            repController.onCollectDataComplete = self.onCollectDataComplete 
        }
        
        if segue.identifier == "SearchSegueID", let srcController = segue.destination as? SearchViewController {
            srcController.dismissOnSelect = true
            srcController.countries = UserManager.shared.getUserCountryList()
            let userInfo = UserManager.shared.userInfo
            searchController = srcController
            searchController?.selectedCountry = UserManager.shared.getCountryName(countryID: userInfo?.countryID)
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        guard company?.certificateURL != nil else {
            toast?.showToastAlert("Missing Certificate Message".localized, type: .info, dismissable: false)
            return
        }
        self.performSegue(withIdentifier: "RepresentativeSegueID", sender: nil)
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func certificateUploadAction(_ sender: Any) {
        toast?.hideToast()
        let importMenu = UIDocumentPickerViewController(documentTypes: [(kUTTypeJPEG as String), (kUTTypePNG as String), (kUTTypePDF as String)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    private func setupTextViews() {
        //TODO: Add the proper regex when defined by design
        nameRTextField.validationRegex          = RichTextFieldView.validName
        nameRTextField.nextResponderField       = addressRTextField.contentTextField
        addressRTextField.validationRegex       = RichTextFieldView.validName
        addressRTextField.nextResponderField    = regNumberRTextField.contentTextField
        regNumberRTextField.validationRegex     = RichTextFieldView.validName
        regNumberRTextField.nextResponderField  = vatRTextField.contentTextField
        vatRTextField.validationRegex           = RichTextFieldView.validName
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
        return !self.fieldsStateDic.values.contains(false) && self.countryRTextField.contentTextField?.text != "Select a country".localized
    }
    
    private func collectData() {
        
        company?.name = nameRTextField.contentTextField?.text ?? ""
        company?.address = addressRTextField.contentTextField?.text ?? ""
        company?.registrationNumber = regNumberRTextField.contentTextField?.text ?? ""
        company?.vat = vatRTextField.contentTextField?.text ?? ""
        company?.country = countryRTextField.contentTextField?.text ?? ""
    }

    private func updateFields() {
        
        let userInfo = UserManager.shared.userInfo
        var countryName = UserManager.shared.getCountryName(countryID: userInfo?.countryID)
        
        if let selectedCountry = self.searchController?.selectedCountry {
            countryName = selectedCountry
        }
        self.countryRTextField.contentTextField?.text = countryName ?? "Select a country".localized
        self.nextButton.isEnabled = self.canContinue()
    }

    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        titleLabelTopConstraint.constant = -34
        stackBottomConstraint.constant   = 124
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    @objc
    func keyboardWillDisappear(notification: NSNotification?) {

        titleLabelTopConstraint.constant = 26
        stackBottomConstraint.constant   = 30
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - UIDocumentPickerDelegate Methods
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        if controller.documentPickerMode == .import {
        
            do {
                let documentData = try Data(contentsOf: url)
                company?.certificateData = documentData
                company?.certificateURL = url
                choosenFileLabel.text = url.lastPathComponent
            }
            catch {
                //TODO
            }
        }
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

