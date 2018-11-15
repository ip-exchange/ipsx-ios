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
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var changePasswordHolderView: RoundedView!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    @IBOutlet weak var individualCheckmarkImage: UIImageView!
    @IBOutlet weak var companyCheckmarkImage: UIImageView!
    @IBOutlet weak var corporateDetailsView: RoundedView!
    @IBOutlet weak var legalOptionsHoldeView: UIView!
    @IBOutlet weak var legalotionsTitleLabel: UILabel!
    @IBOutlet weak var companyApproveLabel: UILabel!
    @IBOutlet weak var companyStatusImageView: UIImageView!
    @IBOutlet weak var companyStatusLabel: UILabel!
    @IBOutlet weak var typeOfUserView: UIView!
    
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
    
    @IBAction func selectIndividualAction(_ sender: Any) {
        
        guard individualCheckmarkImage.isHidden else { return }
        guard hasCompany == false else {
            toast?.showToastAlert("Company To Individual Downgrade Forbiden Message.".localized, autoHideAfter: 5, type: .info, dismissable: true)
            return
        }
        
        toast?.hideToast()
        companyCheckmarkImage.isHidden = true
        individualCheckmarkImage.isHidden = false
        corporateDetailsView.isHidden = true
        
        saveButton.isEnabled = true
        UIView.animate(withDuration: 0.15) { self.view.layoutIfNeeded() }
    }
    
    @IBAction func selectLegalAction(_ sender: Any) {
        
        guard hasCompany == false else { return }
            
        companyCheckmarkImage.isHidden = false
        individualCheckmarkImage.isHidden = true
        corporateDetailsView.isHidden = false
        
        if !addCompanyBannerShown {
            toast?.showToastAlert("Add corporate details toast message".localized, type: .info, dismissable: true)
            addCompanyBannerShown = true
        }
        
        saveButton.isEnabled = true
        UIView.animate(withDuration: 0.15) { self.view.layoutIfNeeded() }
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
        
        getCompanyDetails() {
            self.updateLegalStatusUI()
            self.configureUI()
        }
        
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
                    DispatchQueue.main.async { self.configureUI() }
                    
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
    
    private func configureUI() {
        
        DispatchQueue.main.async {
            
            if UserManager.shared.userInfo?.source == "facebook" {
                
                self.changePasswordHolderView.isHidden = true
                self.typeOfUserView.isHidden = true
            }
            
            self.individualCheckmarkImage.isHidden = UserManager.shared.companyVerified
            self.companyCheckmarkImage.isHidden = !UserManager.shared.companyVerified
            
            //TODO:
            //self.companyPendingCheckmarkImage.isHidden = UserManager.shared.company?.status == .pending
            
            self.companyApproveLabel.isHidden = !(self.hasCompany && !UserManager.shared.companyVerified)
            self.corporateDetailsView.isHidden = !self.hasCompany
        }
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
                self.companyStatusLabel.text = stateText
                self.companyStatusImageView.image = UIImage(named: imageName)
            } else {
                self.companyStatusLabel.text = "Submit your corporate details".localized
                self.companyStatusImageView.image = UIImage(named: "lawBook")
            }
        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        if individualCheckmarkImage.isHidden && !registeredAsCompany && self.company == nil {
            createAndShowCorpDetailsAlert()
            return
        }
        
        if companyEdited {
            
            companyEdited = false
            submitCompanyDetails() { success in
                
                if success {
                    self.getCompanyDetails() { self.updateLegalStatusUI() }
                }
            }
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
        
        if segue.identifier == legalDetailsSegueID {
            let companyNavController = segue.destination as? UINavigationController
            let companyController = companyNavController?.viewControllers.first as? CompanyDetailsController
            companyController?.company = company
            companyController?.nonDismissable = false
            self.editMode = company != nil
            companyController?.editMode = self.editMode
            companyController?.onCollectDataComplete = { company in
                self.companyEdited = true
                self.company = company
            }
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
