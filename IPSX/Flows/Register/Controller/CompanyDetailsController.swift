//
//  CompanyDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class CompanyDetailsController: UIViewController {
    
    @IBOutlet weak var nameRTextField: RichTextFieldView!
    @IBOutlet weak var addressRTextField: RichTextFieldView!
    @IBOutlet weak var regNumberRTextField: RichTextFieldView!
    @IBOutlet weak var vatRTextField: RichTextFieldView!
    @IBOutlet weak var countryRTextField: RichTextFieldView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackBottomConstraint: NSLayoutConstraint!
    
    private var searchController: SearchViewController?
    private var representativeController: RepresentativeDetailsController?
    private var fieldsStateDic: [String : Bool] = ["name" : false, "address" : false, "regNum" : false, "vat" : false]

    var company: Company?
    var onCollectDataComplete: ((_ company: Company)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextViews()
        observreFieldsState()
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
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func certificateUploadAction(_ sender: Any) {
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
        
        let name = nameRTextField.contentTextField?.text ?? ""
        let address = addressRTextField.contentTextField?.text ?? ""
        let registrationNumber = regNumberRTextField.contentTextField?.text ?? ""
        let vat = vatRTextField.contentTextField?.text ?? ""
        let country = countryRTextField.contentTextField?.text ?? ""
        
        company = Company(name: name, address: address, registrationNumber: registrationNumber, vat: vat, country: country, certificateData: nil)
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

}

