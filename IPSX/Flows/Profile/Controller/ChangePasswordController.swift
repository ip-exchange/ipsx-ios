//
//  ChangePasswordController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ChangePasswordController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var oldPassRTField: RichTextFieldView!
    @IBOutlet weak var newPassRTField: RichTextFieldView!
    @IBOutlet weak var newPassBisRTField: RichTextFieldView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    private var fieldsStateDic: [String : Bool] = ["oldPass" : false, "newPass" : false, "newPassBis" : false]

    override func viewDidLoad() {
        super.viewDidLoad()
        observreFieldsState()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    @objc func appWillEnterForeground() {
        updateReachabilityInfo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         setupTextViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
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
            } else {
                self.toast?.hideToastAlert()
            }
        }
    }
    
    func updateReachabilityInfo() {
        DispatchQueue.main.async {
            if ReachabilityManager.shared.isReachable() {
                self.toast?.hideToastAlert()
            } else {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            }
        }
    }

    private func setupTextViews() {
        oldPassRTField.validationRegex       = RichTextFieldView.validPasswordRegex
        oldPassRTField.nextResponderField    = newPassRTField.contentTextField
        newPassRTField.validationRegex       = RichTextFieldView.validPasswordRegex
        newPassRTField.nextResponderField    = newPassBisRTField.contentTextField
        newPassBisRTField.validationRegex    = RichTextFieldView.validPasswordRegex
        newPassBisRTField.mathingTextField   = newPassRTField.contentTextField
    }

    private func observreFieldsState() {
        oldPassRTField.onFieldStateChange = { state in
            self.fieldsStateDic["oldPass"] = state
            let newPassNotTheSame = self.oldPassRTField.contentTextField?.text != self.newPassRTField.contentTextField?.text
            self.saveButton.isEnabled = !self.fieldsStateDic.values.contains(false) && newPassNotTheSame
        }
        newPassRTField.onFieldStateChange = { state in
            self.fieldsStateDic["newPass"] = state
            let newPassNotTheSame = self.oldPassRTField.contentTextField?.text != self.newPassRTField.contentTextField?.text
            self.saveButton.isEnabled = !self.fieldsStateDic.values.contains(false) && newPassNotTheSame
            self.newPassBisRTField.contentTextField?.text = ""
        }
        newPassBisRTField.onFieldStateChange = { state in
            self.fieldsStateDic["newPassBis"] = state
            let newPassNotTheSame = self.oldPassRTField.contentTextField?.text != self.newPassRTField.contentTextField?.text
            self.saveButton.isEnabled = !self.fieldsStateDic.values.contains(false) && newPassNotTheSame
        }
    }

    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        let oldPassword = oldPassRTField.contentTextField?.text ?? ""
        let newPassword = newPassRTField.contentTextField?.text ?? ""
        changePassword(oldPassword: oldPassword, newPassword: newPassword)
    }
    
    func changePassword(oldPassword: String, newPassword: String) {
        
        self.loadingView?.startAnimating()
        
        LoginService().changePassword(oldPassword: oldPassword, newPassword: newPassword, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.autologin(password: newPassword)
            
            case .failure(let error):
                self.handleError(error, requestType: .changePassword, completion: {
                    self.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                })
            }
        })
    }
    
    func autologin(password: String) {
        
        let email = UserManager.shared.email
        loadingView?.startAnimating()
        LoginService().login(email: email, password: password, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.toast?.showToastAlert("Change Password Success Message".localized, autoHideAfter: 5, type: .info)
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.autologinFailed()
                }
            }
        })
    }
    
    func autologinFailed() {
        
        let ac = UIAlertController(title: "Login After Change Password Alert Message".localized, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default) { (action:UIAlertAction) in
            self.performSegue(withIdentifier: "LoginSegueID", sender: nil)
        }
        ac.addAction(okAction)
        present(ac, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LoginSegueID" {
            let loginController = segue.destination as? LoginCredentialsControler
            loginController?.hideBackButton = true
        }
    }
}

extension ChangePasswordController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension ChangePasswordController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
            
        case CustomError.wrongOldPassword:
            self.errorMessage = "Wrong Old Password Error Message".localized
            
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}
