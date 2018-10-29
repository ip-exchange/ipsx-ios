//
//  DeleteAccountController.swift
//  IPSX
//
//  Created by Calin Chitu on 16/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import CVINetworkingFramework

class DeleteAccountController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var passworldRTField: RichTextFieldView!
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
    
    var onDismiss: ((_ hasDeletedAccount: Bool)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        observreFieldsState()
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

    private func setupTextViews() {
        passworldRTField.validationRegex = RichTextFieldView.validPasswordRegex
    }
    
    private func observreFieldsState() {
        passworldRTField.onFieldStateChange = { state in
            self.saveButton.isEnabled = state
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        
        let password = passworldRTField.contentTextField?.text ?? ""
        deleteAccount(password: password)
    }
    
    func deleteAccount(password: String) {
        
        loadingView?.startAnimating()
        
        SettingsService().deleteAccount(password: password, completionHandler: { result in
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                
                DispatchQueue.main.async {
                    self.onDismiss?(true)
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .failure(let error):
                self.handleError(error, requestType: IPRequestType.deleteAccount, completion: {
                    self.deleteAccount(password: password)
                })
            }
        })
    }
}

extension DeleteAccountController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension DeleteAccountController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
            
        case CustomError.wrongPassword:
            self.errorMessage = "Wrong Password Error Message".localized
            
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}
