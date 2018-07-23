//
//  SettingsViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var emailNotificationsSwitch: UISwitch!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var tokensAmountLabel: UILabel!
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    var balance: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.tokensAmountLabel.text = self.balance
            }
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        
        let deleteAccountState = UserManager.shared.userInfo?.deleteAccountState ?? .notRequested
        
        switch deleteAccountState {
            
        case .notRequested:
            performSegue(withIdentifier: "DeleteAccountSegueID", sender: nil)
            
        case .pending, .confirmed:
            abortDelete()
        }
    }
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
        balance = "\(userInfo?.balance ?? 0)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveUserInfo()
        loadSettings()
    }
    
    @IBAction func emailNotificationSwitchAction(_ sender: UISwitch) {
        updateSettings(emailNotif: sender.isOn)
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
                }
                
            case .failure(let error):
                self.handleError(error, requestType: .userInfo, completion: {
                    self.retrieveUserInfo()
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
                self.handleError(error, requestType: .abortDeleteAccount, completion: {
                    self.abortDelete()
                })
            }
        })
    }
    
    func loadSettings() {
        
        loadingView?.startAnimating()
        UserInfoService().getSettings(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let emailNotifValue):
                
                if let emailNotifValue = emailNotifValue as? String, emailNotifValue == EmailNotifications.on {
                    self.updateSwitchValue(value: true)
                }
                else {
                    self.updateSwitchValue(value: false)
                }
               
            case .failure(let error):
                self.handleError(error, requestType: .getSettings, completion: {
                    self.loadSettings()
                })
            }
        })
    }
    
    func updateUI() {
        
        self.balance = "\(UserManager.shared.userInfo?.balance ?? 0)"
        
        let deleteAccountState = UserManager.shared.userInfo?.deleteAccountState ?? .notRequested
        
        switch deleteAccountState {
            
        case .notRequested:
            print("default")
            //TODO(CC): Delete Account button with no banner
            
        case .pending:
            print("pending")
            //TODO(CC): Abort button with "Check your email to confirm your delete account action." banner
            
        case .confirmed:
            print("confirmed")
            //TODO (CC): Abort button with banner "Your account is scheduled to be deleted on @deleteAccountDate"
        }
    }
    
    func updateSettings(emailNotif: Bool = false) {
        
        loadingView?.startAnimating()
        UserInfoService().updateSettings(emailNotif: emailNotif, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                print("success")
                
            case .failure(let error):
                self.handleError(error, requestType: .updateSettings, completion: {
                    self.updateSettings(emailNotif: emailNotif)
                })
            }
        })
    }
    
    func updateSwitchValue(value: Bool = false, error: Bool = false) {
        
        DispatchQueue.main.async {
            self.emailNotificationsSwitch.isEnabled = !error
            self.emailNotificationsSwitch.setOn(value, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

extension SettingsViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension SettingsViewController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.updateSwitchValue(error: true)
                
            }, successHandler: {
                completion?()
            })
        default:
            self.updateSwitchValue(error: true)
        }
    }
}
