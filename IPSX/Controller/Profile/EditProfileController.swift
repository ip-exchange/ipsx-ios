//
//  EditProfileController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EditProfileController: UIViewController {

    @IBOutlet weak var keyIconImageView: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var telegramTextField: UITextField!
    @IBOutlet weak var selectedCountryLabel: UILabel!
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    private var searchController: SearchViewController?
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFields(userInfo: userInfo)
    }
    
    func showCountriesScreen() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SearchSegueID", sender: nil)
        }
    }
    
    private func updateFields(userInfo: UserInfo?) {
        selectedCountryLabel.text = searchController?.selectedCountry ?? "Select a country"
        
        emailTextField.text     = userInfo?.email ?? ""
        firstNameTextField.text = userInfo?.firstName ?? ""
        lastNameTextField.text  = userInfo?.lastName ?? ""
        telegramTextField.text  = userInfo?.telegram ?? ""
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegueID", let srcController = segue.destination as? SearchViewController {
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
            view.addSubview(toastView)
        }
    }
}
