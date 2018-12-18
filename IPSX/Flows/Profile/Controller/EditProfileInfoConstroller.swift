//
//  EditProfileInfoConstroller.swift
//  IPSX
//
//  Created by Calin Chitu on 12/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class EditProfileInfoConstroller: UIViewController {
    
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
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
    
    @IBOutlet weak var fullContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonImageView: UIImageView!
    @IBOutlet weak var deleteButtonTextLabel: UILabel!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var onDismiss: ((_ hasUpdatedProfile: Bool)->())?
    var editMode = false
    
    private var searchController: SearchViewController?
    private var backFromSearch = false
    
    let countrySelectionID  = "SearchSegueID"
    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            let deleteAccountState = UserManager.shared.userInfo?.deleteAccountState ?? .notRequested
            
            switch deleteAccountState {
                
            case .notRequested:
                if UserManager.shared.userInfo?.source == "ios" {
                    self.performSegue(withIdentifier: "DeleteAccountSegueID", sender: nil)
                } else {
                    self.presentDeleteAlert()
                }
                
            case .pending, .confirmed:
                self.abortDelete()
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectCountryAction(_ sender: UIButton) {
        DispatchQueue.main.async { self.performSegue(withIdentifier: self.countrySelectionID, sender: nil) }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func appWillEnterForeground() {
        updateReachabilityInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "Saved".localized)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        updateFields()
        detectChangesAndValidity()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        retrieveUserInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else if self.toast?.currentText == "No internet connection".localized {
                self.toast?.hideToastAlert()
            }
        }
    }
    
    func updateReachabilityInfo() {
        DispatchQueue.main.async {
            if !ReachabilityManager.shared.isReachable() {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else if self.toast?.currentText == "No internet connection".localized {
                self.toast?.hideToastAlert()
            }
        }
    }
    
    private func updateFields() {
        
        let userInfo = UserManager.shared.userInfo
        var countryName = UserManager.shared.getCountryName(countryID: userInfo?.countryID)
        if backFromSearch == true {
            backFromSearch = false
            if let selectedCountry = self.searchController?.selectedCountry {
                countryName = selectedCountry
            }
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
        let countryName = UserManager.shared.getCountryName(countryID: userInfo?.countryID) ?? "Select a country".localized
        var dataChanged = countryName != selectedCountryLabel.text
        
        switch textfield {
        case emailTextField:
            dataChanged = dataChanged || newText != userInfo?.email && isEmailValid(text: newText)
            dataChanged = dataChanged || (firstNameTextField.text != userInfo?.firstName)
            dataChanged = dataChanged || (lastNameTextField.text  != userInfo?.lastName)
            dataChanged = dataChanged || (telegramTextField.text  != userInfo?.telegram)
        case firstNameTextField:
            dataChanged = dataChanged || newText != userInfo?.firstName
            dataChanged = dataChanged || (emailTextField.text    != userInfo?.email)
            dataChanged = dataChanged || (lastNameTextField.text != userInfo?.lastName)
            dataChanged = dataChanged || (telegramTextField.text != userInfo?.telegram)
        case lastNameTextField:
            dataChanged = dataChanged || newText != userInfo?.lastName
            dataChanged = dataChanged || (emailTextField.text     != userInfo?.email)
            dataChanged = dataChanged || (firstNameTextField.text != userInfo?.firstName)
            dataChanged = dataChanged || (telegramTextField.text  != userInfo?.telegram)
        case telegramTextField:
            dataChanged = dataChanged || newText != userInfo?.telegram
            dataChanged = dataChanged || (emailTextField.text     != userInfo?.email)
            dataChanged = dataChanged || (firstNameTextField.text != userInfo?.firstName)
            dataChanged = dataChanged || (lastNameTextField.text  != userInfo?.lastName)
        default:
            break
        }
        
        saveButton.isEnabled = dataChanged
    }
    
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        let countryID = UserManager.shared.getCountryId(countryName: selectedCountryLabel.text ?? "")
        let bodyParams: [String: Any] =  ["email"     : emailTextField.text ?? "",
                                          "first_name": firstNameTextField.text?.trimLeadingAndTrailingSpaces() ?? "",
                                          "last_name" : lastNameTextField.text?.trimLeadingAndTrailingSpaces() ?? "",
                                          "telegram"  : telegramTextField.text?.trimLeadingAndTrailingSpaces() ?? "",
                                          "country_id": countryID as Any]
        
        self.updateUserProfile(bodyParams: bodyParams)
    }
    
    func updateUserProfile(bodyParams: [String: Any], companyError: Bool = false) {
        
        loadingView?.startAnimating()
        UserInfoService().updateUserProfile(bodyParams: bodyParams, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                self.getNewUserInfo() {
                    DispatchQueue.main.async {
                        
                        if !companyError {
                            self.onDismiss?(true)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            case .failure(let error):
                self.handleError(error, requestType: RequestType.updateProfile, completion: {
                    self.updateUserProfile(bodyParams: bodyParams)
                })
            }
        })
    }
    
    func getNewUserInfo(successCompletion: @escaping () -> ()) {
        
        self.loadingView?.startAnimating()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                successCompletion()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.getNewUserInfo(successCompletion: successCompletion)
                })
            }
        })
    }
    
    private func isEmailValid(text: String) -> Bool {
        let validityTest = NSPredicate(format:"SELF MATCHES %@", RichTextFieldView.validEmailRegex)
        return validityTest.evaluate(with: text)
    }
    
    func updateUI() {
        
        let deleteAccountState = UserManager.shared.userInfo?.deleteAccountState ?? .notRequested
        let deleteDate = UserManager.shared.userInfo?.deleteAccountDate
        let deleteDateString = deleteDate?.dateToString(format: "dd MMM yyyy") ?? "--:--:--"
        
        switch deleteAccountState {
            
        case .notRequested:
            deleteButtonImageView.image = UIImage(named: "garbage")
            deleteButtonTextLabel.text = "Delete Account".localized
            toast?.hideToast()
            
        case .pending:
            deleteButtonImageView.image = UIImage(named: "cancelDelete")
            deleteButtonTextLabel.text = "Abort Delete Account".localized
            toast?.showToastAlert("Delete Confirm Email Message".localized, type: .deletePending, dismissable: false)
            
        case .confirmed:
            deleteButtonImageView.image = UIImage(named: "cancelDelete")
            deleteButtonTextLabel.text = "Abort Delete Account".localized
            let deleteMessage = String(format: "Delete Scheduled Message %@".localized, "\(deleteDateString)")
            toast?.showToastAlert(deleteMessage, type: .deleteConfirmed, dismissable: false)
        }
    }

    func retrieveUserInfo() {
        
        loadingView?.startAnimating()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(let user):
                
                UserManager.shared.userInfo = user as? UserInfo
                DispatchQueue.main.async {
                    self.updateUI()
                    self.updateFields()
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.retrieveUserInfo()
                })
            }
        })
    }

    private func presentDeleteAlert() {
        
        let alertController = UIAlertController(title: "Delete Account Confirm Message".localized, message: "".localized, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .default) { (action:UIAlertAction) in
        }
        
        let deleteAction = UIAlertAction(title: "Confirm".localized, style: .destructive) { (action:UIAlertAction) in
            self.deleteAccount()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func deleteAccount() {
        
        loadingView?.startAnimating()
        
        SettingsService().deleteAccount(completionHandler: { result in
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                
                DispatchQueue.main.async {
                    self.retrieveUserInfo()
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.deleteAccount, completion: {
                    self.deleteAccount()
                })
            }
        })
    }

    func abortDelete() {
        
        loadingView?.startAnimating()
        SettingsService().abortDeleteAccount(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.retrieveUserInfo()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.abortDeleteAccount, completion: {
                    self.abortDelete()
                })
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == countrySelectionID, let srcController = segue.destination as? SearchViewController {
            srcController.onCountrySelected = { selectedCountry in
                self.selectedCountryLabel.text = selectedCountry
            }
            backFromSearch = true
            srcController.dismissOnSelect = true
            srcController.countries = UserManager.shared.getCountryList()
            let userInfo = UserManager.shared.userInfo
            searchController = srcController
            searchController?.selectedCountry = UserManager.shared.getCountryName(countryID: userInfo?.countryID)
        }
        
        if segue.identifier == "DeleteAccountSegueID" {
            let deleteAccController = segue.destination as? DeleteAccountController
            deleteAccController?.onDismiss = { success in
                if success {
                    self.retrieveUserInfo()
                }
            }
        }
    }
}

extension EditProfileInfoConstroller: UITextFieldDelegate {
    
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

extension EditProfileInfoConstroller: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}
extension EditProfileInfoConstroller: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            
            switch requestType {
            case RequestType.userInfo:
                self.errorMessage = "User Info Error Message".localized
            case RequestType.getCompany:
                self.errorMessage = "Get Company Details Error Message".localized
            default:
                self.errorMessage = "Generic Error Message".localized
            }
            
        }
    }
}
