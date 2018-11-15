//
//  SettingsViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class SettingsViewController: UIViewController {

    @IBOutlet weak var emailNotificationsSwitch: UISwitch!
    @IBOutlet weak var newsletterSwitch: UISwitch!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    var emailNotif = true
    var newsletter = true
    
    @IBOutlet weak var loadingView: CustomLoadingView!
 
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsletterSwitch.setOn(UserManager.shared.newsletterNotifications, animated: false)
        emailNotificationsSwitch.setOn(UserManager.shared.emailNotifications, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
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
        
        emailNotif = sender.isOn
        newsletter = newsletterSwitch.isOn
        updateSettings()
    }
    
    @IBAction func newsletterSwitchAction(_ sender: UISwitch) {
        
        newsletter = sender.isOn
        emailNotif = emailNotificationsSwitch.isOn
        updateSettings()
    }
    
    func loadSettings() {
        
        loadingView?.startAnimating()
        UserInfoService().getSettings(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let result):
                
                if let result = result as? (String, Newsletter) {
                    
                    self.updateEmailNotifSwitch(value: result.0 == EmailNotifications.on)
                    self.updateNewsletterSwitch(value: result.1 == Newsletter.on)
                }
        
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getSettings, completion: {
                    self.loadSettings()
                })
            }
        })
    }
    
    func updateSettings() {
        
        loadingView?.startAnimating()
        UserInfoService().updateSettings(emailNotif: emailNotif, newsletter: newsletter, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                break
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.updateSettings, completion: {
                    self.updateSettings()
                })
            }
        })
    }
    
    func updateEmailNotifSwitch(value: Bool = false, error: Bool = false) {
        
        DispatchQueue.main.async {
            self.emailNotificationsSwitch.isEnabled = !error
            self.emailNotificationsSwitch.setOn(value, animated: true)
        }
    }
    
    func updateNewsletterSwitch(value: Bool = true, error: Bool = false) {
        
        DispatchQueue.main.async {
            self.newsletterSwitch.isEnabled = !error
            self.newsletterSwitch.setOn(value, animated: true)
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
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.updateEmailNotifSwitch(error: true)
                self.updateNewsletterSwitch(error: true)
                
            }, successHandler: {
                completion?()
            })
            
        default:
            
            switch requestType {
                
            case RequestType.updateSettings:
                self.updateEmailNotifSwitch(error: true)
                self.updateNewsletterSwitch(error: true)
                
            default:
                self.errorMessage = "Generic Error Message".localized
            }
            
        }
    }
}
