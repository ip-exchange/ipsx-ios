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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var telegramTextField: UITextField!
    @IBOutlet weak var selectedCountryLabel: UILabel!
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
                    self.updateFields()
                    
                case .failure(_):
                    self.errorMessage = "Generic Error Message".localized
                }
            })
        }
    }
    
    private func updateFields() {
        
        DispatchQueue.main.async {
            
            let userInfo = UserManager.shared.userInfo
            var countryName = UserDefaults.standard.getCountryName(countryID: userInfo?.countryID)
            if let selectedCountry = self.searchController?.selectedCountry {
                countryName = selectedCountry
            }
            self.selectedCountryLabel.text = countryName ?? "Select a country".localized
            self.emailTextField.text       = userInfo?.email
            self.firstNameTextField.text   = userInfo?.firstName
            self.lastNameTextField.text    = userInfo?.lastName
            self.telegramTextField.text    = userInfo?.telegram
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == countrySelectionID, let srcController = segue.destination as? SearchViewController {
            srcController.dismissOnSelect = true
            srcController.countries = UserDefaults.standard.getUserCountryList()
            searchController = srcController
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
