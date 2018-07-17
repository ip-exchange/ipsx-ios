//
//  DeleteAccountController.swift
//  IPSX
//
//  Created by Calin Chitu on 16/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

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
        print(password)
        loadingView.startAnimating()
        //TODO (CVI): Delete logic here. If success, should dismiss this screen and invoke landing page segue from tabbar
        //TODO (CVI): Dummy code to simulate a delete request, replace it with the actual request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loadingView.stopAnimating()
            self.onDismiss?(true)
            self.navigationController?.popViewController(animated: true)
        }
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
