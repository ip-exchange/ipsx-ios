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
    @IBOutlet weak var deleteButtonImageView: UIImageView!
    @IBOutlet weak var deleteButtonTextLabel: UILabel!

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
        balance = userInfo?.balance.cleanString ?? "0"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        retrieveUserInfo()
        loadSettings()
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
        
        self.balance = UserManager.shared.userInfo?.balance.cleanString ?? "0" 
        
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
            
            switch requestType {
                
            case .updateSettings:
                self.updateSwitchValue(error: true)
                
            default:
                self.errorMessage = "Generic Error Message".localized
            }
            
        }
    }
}
