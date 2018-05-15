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
    
    private var searchController: SearchViewController?
    let countrySelectionID = "SearchSegueID"
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func selectCountryAction(_ sender: UIButton) {
        
        //TODO (CVI): Determine when should we load the countries
        //Temp solution:
        
        if UserDefaults.standard.getUserCountryList().count == 0 {
            UserInfoService().getUserCountryList(completionHandler: { result in
                switch result {
                case .success(let countryList):
                    guard let countryList = countryList as? [[String: String]] else {
                        self.errorMessage = "Generic Error Message".localized
                        return
                    }
                    UserDefaults.standard.storeUserCountryList(countryArray: countryList)
                    self.showCountriesScreen()
                    
                case .failure(_):
                    self.errorMessage = "Generic Error Message".localized
                }
            })
        }
        else {
            showCountriesScreen()
        }
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
        updateFields(userInfo: userInfo)
    }
    
    func showCountriesScreen() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.countrySelectionID, sender: nil)
        }
    }
    
    private func updateFields(userInfo: UserInfo?) {
    
        var countryName = UserDefaults.standard.getCountryName(countryID: userInfo?.countryID)
        if let selectedCountry = searchController?.selectedCountry {
            countryName = selectedCountry
        }
        selectedCountryLabel.text = countryName ?? "Select a country".localized
        emailTextField.text       = userInfo?.email
        firstNameTextField.text   = userInfo?.firstName
        lastNameTextField.text    = userInfo?.lastName
        telegramTextField.text    = userInfo?.telegram
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
            
            DispatchQueue.main.async { self.loadingView.stopAnimating() }
            switch result {
            case .success(_):
                self.getNewUserInfo() { success in
                    if success {
                        DispatchQueue.main.async {
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
                
            case .success(_):
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
