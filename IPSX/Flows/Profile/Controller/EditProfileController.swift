//
//  EditProfileController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EditProfileController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var keyIconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField! {
        didSet { emailTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged) }
    }
    @IBOutlet weak var firstNameTextField: UITextField!{
        didSet { firstNameTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged) }
    }
    @IBOutlet weak var lastNameTextField: UITextField!{
        didSet { lastNameTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged) }
    }
    @IBOutlet weak var telegramTextField: UITextField!{
        didSet { telegramTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged) }
    }
    @IBOutlet weak var selectedCountryLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }

    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var onDismiss: ((_ hasUpdatedProfile: Bool)->())?
    private var searchController: SearchViewController?
    
    let countrySelectionID = "SearchSegueID"
    let validEmailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func selectCountryAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: self.countrySelectionID, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyIconImageView.tintColor = .lightBlue
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "Saved".localized)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFields()
        detectChangesAndValidity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserManager.shared.userCountries == nil {
            
            loadingView.startAnimating()
            UserInfoService().getUserCountryList(completionHandler: { result in
                
                self.loadingView.stopAnimating()
                switch result {
                case .success(let countryList):
                    UserManager.shared.userCountries = countryList as? [[String: String]]
                    DispatchQueue.main.async { self.updateFields() }
                    
                case .failure(_):
                    self.errorMessage = "Generic Error Message".localized
                }
            })
        }
    }
    
    private func updateFields() {
        
        let userInfo = UserManager.shared.userInfo
        var countryName = UserDefaults.standard.getCountryName(countryID: userInfo?.countryID)
        if let selectedCountry = self.searchController?.selectedCountry {
            countryName = selectedCountry
         } else {
            self.emailTextField.text       = userInfo?.email
            self.firstNameTextField.text   = userInfo?.firstName
            self.lastNameTextField.text    = userInfo?.lastName
            self.telegramTextField.text    = userInfo?.telegram
        }
        self.selectedCountryLabel.text = countryName ?? "Select a country".localized

    }
    
    private func detectChangesAndValidity(textfield: UITextField? = nil, newText: String = "") {
        
        let userInfo = UserManager.shared.userInfo
        let countryName = UserDefaults.standard.getCountryName(countryID: userInfo?.countryID) ?? "Select a country".localized
        var dataChanged = countryName != selectedCountryLabel.text
        
        switch textfield {
        case emailTextField:
            dataChanged = dataChanged || newText != userInfo?.email && isEmailValid(text: newText)
            dataChanged = dataChanged || (firstNameTextField.text != userInfo?.firstName)
            dataChanged = dataChanged || (lastNameTextField.text  != userInfo?.lastName)
            dataChanged = dataChanged || (telegramTextField.text  != userInfo?.telegram)
            dataChanged = dataChanged && firstNameTextField.text  != "" && lastNameTextField.text != "" && telegramTextField.text != "" && newText.count > 0
        case firstNameTextField:
            dataChanged = dataChanged || newText != userInfo?.firstName
            dataChanged = dataChanged || (emailTextField.text    != userInfo?.email)
            dataChanged = dataChanged || (lastNameTextField.text != userInfo?.lastName)
            dataChanged = dataChanged || (telegramTextField.text != userInfo?.telegram)
            dataChanged = dataChanged && lastNameTextField.text != "" && telegramTextField.text != "" && isEmailValid(text: emailTextField.text ?? "") && newText.count > 0
        case lastNameTextField:
            dataChanged = dataChanged || newText != userInfo?.lastName
            dataChanged = dataChanged || (emailTextField.text     != userInfo?.email)
            dataChanged = dataChanged || (firstNameTextField.text != userInfo?.firstName)
            dataChanged = dataChanged || (telegramTextField.text  != userInfo?.telegram)
            dataChanged = dataChanged && firstNameTextField.text  != "" && telegramTextField.text != "" && isEmailValid(text: emailTextField.text ?? "") && newText.count > 0
        case telegramTextField:
            dataChanged = dataChanged || newText != userInfo?.telegram
            dataChanged = dataChanged || (emailTextField.text     != userInfo?.email)
            dataChanged = dataChanged || (firstNameTextField.text != userInfo?.firstName)
            dataChanged = dataChanged || (lastNameTextField.text  != userInfo?.lastName)
            dataChanged = dataChanged && firstNameTextField.text  != "" && lastNameTextField.text != "" && isEmailValid(text: emailTextField.text ?? "") && newText.count > 0
        default:
            break
        }
        
        saveButton.isEnabled = dataChanged && selectedCountryLabel.text != "Select a country".localized
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        let countryID = UserDefaults.standard.getCountryId(countryName: selectedCountryLabel.text ?? "")
        let bodyParams: [String: String] =  ["email"     : emailTextField.text ?? "",
                                             "first_name": firstNameTextField.text ?? "",
                                             "last_name" : lastNameTextField.text ?? "",
                                             "telegram"  : telegramTextField.text ?? "",
                                             "country_id": countryID ?? ""]
        
        loadingView.startAnimating()
        UserInfoService().updateUserProfile(bodyParams: bodyParams, completionHandler: { result in
            
            self.loadingView.stopAnimating() 
            switch result {
            case .success(_):
                self.getNewUserInfo() { success in
                    if success {
                        DispatchQueue.main.async {
                            self.onDismiss?(true)
                            self.performSegue(withIdentifier: "showTabBarSegueID", sender: nil)
                        }
                    }
                    else {
                        self.errorMessage = "User Info Error Message".localized
                    }
                }
            case .failure(_):
                self.errorMessage = "Generic Error Message".localized
            }
        })
    }
    
    func getNewUserInfo(completion:@escaping (Bool) -> ()) {
        
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            switch result {
                
            case .failure(_):
                completion(false)
                
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                completion(true)
            }
        })
    }
    
    private func isEmailValid(text: String) -> Bool {
        let validityTest = NSPredicate(format:"SELF MATCHES %@", validEmailRegex)
        return validityTest.evaluate(with: text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == countrySelectionID, let srcController = segue.destination as? SearchViewController {
            srcController.dismissOnSelect = true
            srcController.countries = UserDefaults.standard.getUserCountryList()
            let userInfo = UserManager.shared.userInfo
            searchController = srcController
            searchController?.selectedCountry = UserDefaults.standard.getCountryName(countryID: userInfo?.countryID)
        }
    }
}

extension EditProfileController: UITextFieldDelegate {
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        if let newString = textField.text {
            //THE PASSWORD MUST BE AT LEAST 8 CHARACTERS, ONE NUMBER, ONE UPPERCASE CHARACTER AND ONE SPECIAL CHARACTER @$!%*?&
            detectChangesAndValidity(textfield: textField, newText: newString)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard  !textField.isSecureTextEntry else { return true }
        
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        detectChangesAndValidity(textfield: textField, newText: newString)
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleTextfieldFocusChange(for: textField, actionOnDone: true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.returnKeyType = textField == telegramTextField ? .done : .next
        return true
    }
    
    private func handleTextfieldFocusChange(for textField: UITextField, actionOnDone: Bool) {
        
        detectChangesAndValidity(textfield: textField, newText: textField.text ?? "")
        switch textField {
        case emailTextField: firstNameTextField.becomeFirstResponder()
        case firstNameTextField: lastNameTextField.becomeFirstResponder()
        case lastNameTextField: telegramTextField.becomeFirstResponder()
        case telegramTextField: textField.resignFirstResponder()
       default:
            break
        }
    }
}

extension EditProfileController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}
