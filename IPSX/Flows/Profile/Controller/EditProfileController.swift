//
//  EditProfileController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

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
    @IBOutlet weak var changePasswordHolderView: RoundedView!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }

    @IBOutlet weak var fullContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var individualCheckmarkImage: UIImageView!
    @IBOutlet weak var legalCheckmarkImage: UIImageView!
    @IBOutlet weak var corporateDetailsView: RoundedView!
    @IBOutlet weak var legalOptionsHoldeView: UIView!
    @IBOutlet weak var legalotionsTitleLabel: UILabel!
    
    @IBOutlet weak var corporateStatusImageView: UIImageView!
    @IBOutlet weak var corporateStatusLabel: UILabel!
    
    var company: Company? = UserManager.shared.company
        
    var registeredAsCompany = UserManager.shared.userInfo?.hasOptedForLegal == true
    var hasCompany = UserManager.shared.company != nil
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var onDismiss: ((_ hasUpdatedProfile: Bool)->())?
    var addCompanyBannerShown = false
    var editMode = false
    
    private var searchController: SearchViewController?
    private var backFromSearch = false
    private var companyEdited = false
    
    let countrySelectionID  = "SearchSegueID"
    let legalDetailsSegueID = "LegalDetailsSegueID"
    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func selectCountryAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: self.countrySelectionID, sender: nil)
    }
    
    @IBAction func selectIndividualAction(_ sender: Any) {
        
        guard !(registeredAsCompany || hasCompany) else {
            toast?.showToastAlert("Legal To Individual Downgrade Forbiden Message.".localized, autoHideAfter: 5, type: .info, dismissable: true)
            return
        }
        
        self.toast?.hideToast()
        self.legalCheckmarkImage.isHidden = true
        self.individualCheckmarkImage.isHidden = false
        self.corporateDetailsView.isHidden = true
        
        self.saveButton.isEnabled = true
        self.fullContentHeightConstraint.constant -= 66
        UIView.animate(withDuration: 0.15) { self.view.layoutIfNeeded() }
    }
    
    @IBAction func selectLegalAction(_ sender: Any) {
        
        self.legalCheckmarkImage.isHidden = false
        self.individualCheckmarkImage.isHidden = true
        self.corporateDetailsView.isHidden = false
        
        if !(registeredAsCompany || hasCompany) {
            
            if !addCompanyBannerShown {
                toast?.showToastAlert("Add corporate details toast message".localized, type: .info, dismissable: true)
                addCompanyBannerShown = true
            }
            
            self.saveButton.isEnabled = true
            self.fullContentHeightConstraint.constant += 66
            UIView.animate(withDuration: 0.15) { self.view.layoutIfNeeded() }
        }
    }
    
    @IBAction func corporateDetailsAction(_ sender: Any) {
        self.view.endEditing(true)
        self.toast?.hideToast()
        
        if UserManager.shared.userInfo?.hasOptedForLegal == true {
            getCompanyDetails() { self.performSegue(withIdentifier: self.legalDetailsSegueID, sender: nil) }
        } else {
            self.performSegue(withIdentifier: "LegalDetailsSegueID", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyIconImageView.tintColor = .lightBlue
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        prepareUI()
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
        getCompanyDetails() { self.updateLegalStatusUI() }
        if companyEdited { saveButton.isEnabled = true }
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()

        // After Logout
        if UserManager.shared.userCountries == nil {
            
            loadingView?.startAnimating()
            UserInfoService().getUserCountryList(completionHandler: { result in
                
                self.loadingView?.stopAnimating()
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
    
    private func prepareUI() {
        if UserManager.shared.userInfo?.source != "ios" {
            self.fullContentHeightConstraint.constant -= 66
            self.legalOptionsHoldeView.isHidden = true
            self.legalotionsTitleLabel.isHidden = true
        }
        if (registeredAsCompany || hasCompany) {
            self.legalCheckmarkImage.isHidden = false
        } else {
            self.individualCheckmarkImage.isHidden = false
            self.fullContentHeightConstraint.constant -= 66
            self.corporateDetailsView.isHidden = true
        }
    }
    
    private func updateFields() {
        
        let userInfo = UserManager.shared.userInfo
        var countryName = UserManager.shared.getCountryName(countryID: userInfo?.countryID)
        changePasswordHolderView.isHidden = userInfo?.source != "ios"
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
    
    private func updateLegalStatusUI() {
        
        DispatchQueue.main.async {
            if let company = self.company {
                var imageName = "corporatePending"
                var stateText = "Your corporate data is being reviewed".localized
                switch company.status {
                case .pending:
                    imageName = "corporatePending"
                    stateText = "Your corporate data is being reviewed".localized
                case .incomplete:
                    imageName = "corporateReject"
                    stateText = "Your data is incomplete".localized
                case .rejected:
                    imageName = "corporateReject"
                    stateText = "Your data has been rejected".localized
                case .verified:
                    imageName = "corporateSuccess"
                    stateText = "Your data has been reviewed".localized
                case .collected:
                    imageName = "lawBook"
                    stateText = "Your data is ready to submit".localized
                case .unknown:
                    imageName = "corporateReject"
                    stateText = "Your status is unknown, contact support".localized
                }
                self.corporateStatusLabel.text = stateText
                self.corporateStatusImageView.image = UIImage(named: imageName)
            } else {
                self.corporateStatusLabel.text = "Submit your corporate details".localized
                self.corporateStatusImageView.image = UIImage(named: "lawBook")
            }
        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        if individualCheckmarkImage.isHidden && !registeredAsCompany && self.company == nil {
            createAndShowCorpDetailsAlert()
            return
        }
        
        let countryID = UserManager.shared.getCountryId(countryName: selectedCountryLabel.text ?? "")
        let bodyParams: [String: Any] =  ["email"     : emailTextField.text ?? "",
                                          "first_name": firstNameTextField.text?.trimLeadingAndTrailingSpaces() ?? "",
                                          "last_name" : lastNameTextField.text?.trimLeadingAndTrailingSpaces() ?? "",
                                          "telegram"  : telegramTextField.text?.trimLeadingAndTrailingSpaces() ?? "",
                                          "country_id": countryID as Any]
        
        if companyEdited {
            
            companyEdited = false
            submitCompanyDetails() { success in
                
                if success {
                    self.getCompanyDetails() { self.updateLegalStatusUI() }
                }
                self.updateUserProfile(bodyParams: bodyParams, companyError: !success)
            }
        }
        else {
            self.updateUserProfile(bodyParams: bodyParams)
        }
    }
    
    private func createAndShowCorpDetailsAlert() {
        let alertController = UIAlertController(title: "Add Company Alert Title".localized, message: "Add Company Alert Body".localized, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .default) { (action:UIAlertAction) in
        }
        
        let addAction = UIAlertAction(title: "Add".localized, style: .default) { (action:UIAlertAction) in
            self.performSegue(withIdentifier: "LegalDetailsSegueID", sender: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: true, completion: nil)
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
                            self.performSegue(withIdentifier: "showTabBarSegueID", sender: nil)
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
    
    func getCompanyDetails(completion: (()->())? = nil) {
        
        self.loadingView?.startAnimating()
        LegalPersonService().getCompanyDetails(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            
            switch result {
                
            case .success(let company):
                UserManager.shared.company = company as? Company
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getCompany, completion: {
                    self.getCompanyDetails()
                })
            }
            DispatchQueue.main.async { completion?() }
        })
    }
    
    func submitCompanyDetails(completion: @escaping (Bool) -> ()) {
        
        loadingView?.startAnimating()
        LegalPersonService().submitLegalDetails(companyDetails: company, editMode: editMode) { result in
            self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                completion(true)
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.submitLegalPersonDetails, completion: {
                    self.submitCompanyDetails(completion: completion)
                })
            }
        }
    }
    
    private func isEmailValid(text: String) -> Bool {
        let validityTest = NSPredicate(format:"SELF MATCHES %@", RichTextFieldView.validEmailRegex)
        return validityTest.evaluate(with: text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == countrySelectionID, let srcController = segue.destination as? SearchViewController {
            backFromSearch = true
            srcController.dismissOnSelect = true
            srcController.countries = UserManager.shared.getUserCountryList()
            let userInfo = UserManager.shared.userInfo
            searchController = srcController
            searchController?.selectedCountry = UserManager.shared.getCountryName(countryID: userInfo?.countryID)
        }
        if segue.identifier == legalDetailsSegueID {
            let companyNavController = segue.destination as? UINavigationController
            let companyController = companyNavController?.viewControllers.first as? CompanyDetailsController
            companyController?.company = company
            companyController?.nonDismissable = false
            self.editMode = company != nil
            companyController?.editMode = self.editMode
            companyController?.lastStepForLegalRegistration = false
            companyController?.onCollectDataComplete = { company in
                self.companyEdited = true
                self.company = company
            }
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
extension EditProfileController: ErrorPresentable {
    
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
