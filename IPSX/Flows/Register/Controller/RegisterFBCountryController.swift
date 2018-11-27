//
//  RegisterFBCountryController.swift
//  IPSX
//
//  Created by Calin Chitu on 06/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

@IBDesignable
class RegisterFBCountryController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var countryRTextField: RichTextFieldView!
    @IBOutlet weak var bottomContinueConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButton: RoundedButton!
    
    var fbToken: String = ""
    var continueBottomDist: CGFloat = 0.0

    private var fieldsStateDic: [String : Bool] = ["country_id": false]
    private var searchController: SearchViewController?
    private var country: String? {
        didSet {
            DispatchQueue.main.async {
                self.countryRTextField.contentTextField?.text = self.country
            }
        }
    }
    
    var userCredentials: [String: String] = ["email": "", "pass": "", "country_id": ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueBottomDist = bottomContinueConstraint.constant
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let selectedCountry = searchController?.selectedCountry {
            countryRTextField.contentTextField?.text = selectedCountry
        }
        
        if UserManager.shared.allCountries == nil {
            
            UserInfoService().getUserCountryList(completionHandler: { result in
                
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
    }
        
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToRegCredentials(segue:UIStoryboardSegue) { }
    
    @IBAction func continueAction(_ sender: Any) {
        performSegue(withIdentifier: "TermsSegueID", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TermsSegueID" {
            if let countryID = self.userCredentials["country_id"] {
                let nextScreen = segue.destination as? RegisterTermsController
                nextScreen?.userCredentials = ["email": "", "pass": "", "country_id": countryID]
                nextScreen?.fbToken = fbToken
            }
        }
        
        if segue.identifier == "SrcSegueID", let srcController = segue.destination as? SearchViewController {
            srcController.onCountrySelected = { selectedCountry in
                self.country = selectedCountry
                let countryID = UserManager.shared.getCountryId(countryName: selectedCountry) ?? ""
                self.userCredentials["country_id"] = countryID
                self.fieldsStateDic["country_id"] = true
                self.continueButton.isEnabled = !self.fieldsStateDic.values.contains(false)
            }
            
            srcController.dismissOnSelect = true
            srcController.countries = UserManager.shared.getUserCountryList()
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
