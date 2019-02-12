//
//  RegCredentialsController.swift
//  IPSXSandbox
//
//  Created by Calin Chitu on 17/04/2018.
//  Copyright © 2018 Calin Chitu. All rights reserved.
//

import UIKit

@IBDesignable
class RegisterCredentialsController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userNameRichTextView: RichTextFieldView!
    @IBOutlet weak var emailRichTextView: RichTextFieldView!
    @IBOutlet weak var countryRTextField: RichTextFieldView!
    @IBOutlet weak var bottomContinueConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButton: RoundedButton!
    
    var continueBottomDist: CGFloat = 0.0
    private var fieldsStateDic: [String : Bool] = ["username" : false, "email" : false, "country_id": false]
    private var searchController: SearchViewController?
    var country: String? {
        didSet {
            DispatchQueue.main.async {
                self.countryRTextField.contentTextField?.text = self.country
            }
        }
    }
    
    var userCredentials: [String: String] = ["username" : "", "email" : "", "country_id" : ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueBottomDist = bottomContinueConstraint.constant
        observreFieldsState()
        userNameRichTextView.updateColors(isValid: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let selectedCountry = searchController?.selectedCountry {
            countryRTextField.contentTextField?.text = selectedCountry
        }

        if UserManager.shared.allCountries == nil {
            
            UserInfoService().getCountryList(completionHandler: { result in
                
                switch result {
                case .success(let countryList):
                    UserManager.shared.allCountries = countryList as? [[String: String]]
                    
                case .failure(_): break
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        backgroundImageView.removeParticlesAnimation()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
        setupTextViews()
    }
    
    private func setupTextViews() {
        emailRichTextView.validationRegex = RichTextFieldView.validEmailRegex
        userNameRichTextView.validationRegex = RichTextFieldView.minOneCharRegex
    }
    
    private func observreFieldsState() {
        userNameRichTextView.onFieldStateChange = { [weak self] state in
            
            guard let weakSelf = self else { return }
            weakSelf.fieldsStateDic["username"] = state
            weakSelf.continueButton.isEnabled = !weakSelf.fieldsStateDic.values.contains(false)
        }
        emailRichTextView.onFieldStateChange = { [weak self] state in
            
            guard let weakSelf = self else { return }
            weakSelf.fieldsStateDic["email"] = state
            weakSelf.continueButton.isEnabled = !weakSelf.fieldsStateDic.values.contains(false)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToRegCredentials(segue:UIStoryboardSegue) { }
    
    @IBAction func continueAction(_ sender: Any) {
        DispatchQueue.main.async { self.performSegue(withIdentifier: "PasswordSegueID", sender: self) }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PasswordSegueID" {
            if let username = userNameRichTextView.contentTextField?.text, let email = emailRichTextView.contentTextField?.text, let countryID = self.userCredentials["country_id"] {
                let nextScreen = segue.destination as? RegisterPasswordController
                nextScreen?.userCredentials = ["username" : username, "email": email, "country_id": countryID]
            }
        }
        
        if segue.identifier == "SearchSegueID", let srcController = segue.destination as? SearchViewController {
            srcController.onCountrySelected = { [weak self] selectedCountry in
                
                guard let weakSelf = self else { return }
                weakSelf.country = selectedCountry
                let countryID = UserManager.shared.getCountryId(countryName: selectedCountry) ?? ""
                weakSelf.userCredentials["country_id"] = countryID
                weakSelf.fieldsStateDic["country_id"] = true
                weakSelf.continueButton.isEnabled = !weakSelf.fieldsStateDic.values.contains(false)
            }
            
            srcController.dismissOnSelect = true
            srcController.countries = UserManager.shared.getCountryList()
            let userInfo = UserManager.shared.userInfo
            searchController = srcController
            searchController?.selectedCountry = UserManager.shared.getCountryName(countryID: userInfo?.countryID)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        bottomContinueConstraint.constant = keyboardHeight + 10
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        bottomContinueConstraint.constant = continueBottomDist
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
}

