//
//  LoginCredentialsControler.swift
//  IPSX
//
//  Created by Calin Chitu on 23/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class LoginCredentialsControler: UIViewController {
    
    @IBOutlet weak var emailRichTextView: RichTextFieldView!
    @IBOutlet weak var passRichTextField: RichTextFieldView!
    @IBOutlet weak var bottomContinueConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButton: RoundedButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    var hideBackButton = false
    var continueBottomDist: CGFloat = 0.0
    private var fieldsStateDic: [String : Bool] = ["email" : false, "pass" : false]
    var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        
        //TODO (CVI): add activity indicator
        
        LoginService().login(email: emailRichTextView.contentTextField?.text, password: passRichTextField.contentTextField?.text, completionHandler: { result in
            //TODO (CVI): remove activity indicator
            
            switch result {
                
            case .success(let success):
                
                if (success as? Bool) == true {
                    self.continueFlow()
                }
                else {
                    self.errorMessage = "Generic Error Message".localized
                }
                
            case .failure(let error):
                
                guard let customError = error as? CustomError else {
                    self.errorMessage = "Generic Error Message".localized
                    return
                }
                switch customError {
                case .statusCodeNOK(let statusCode):
                    
                    switch statusCode {
                    case 401:
                        self.errorMessage = "Login Failed Error Message".localized
                        
                    case 403:
                        self.errorMessage = "Invalid Login Error Message".localized
                        
                    default:
                        self.errorMessage = "Login Failed Error Message".localized
                    }
                    
                default:
                    self.errorMessage = "Generic Error Message".localized
                    break
                }
            }
        })
    }
    
    func continueFlow() {
        
        UserInfoService().retrieveETHaddresses(completionHandler: { result in
            
            switch result {
                
            case .success(let ethAddresses):
                
                guard let ethAddresses = ethAddresses as? [EthAddress] else {
                    self.errorMessage = "Generic Error Message".localized
                    return
                }
                UserManager.shared.storeEthAddresses(ethAddresses: ethAddresses)
                
                DispatchQueue.main.async {
                    if UserManager.shared.hasEthAddress {
                        self.performSegue(withIdentifier: "showDashboardSegueID", sender: nil)
                    }
                    else {
                        self.performSegue(withIdentifier: "showAddWalletSegueID", sender: nil)
                    }
                }
                
            case .failure(_):
                
                self.errorMessage = "Generic Error Message".localized
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueBottomDist = bottomContinueConstraint.constant
        backButton.isHidden = hideBackButton
        observreFieldsState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "Invalid Credentials")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTextViews()
    }
    
    private func setupTextViews() {
        emailRichTextView.validationRegex       = RichTextFieldView.validEmailRegex
        emailRichTextView.nextResponderField    = passRichTextField.contentTextField
        passRichTextField.validationRegex       = RichTextFieldView.validPasswordRegex
    }
    
    private func observreFieldsState() {
        emailRichTextView.onFieldStateChange = { state in
            self.fieldsStateDic["email"] = state
            self.continueButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
        passRichTextField.onFieldStateChange = { state in
            self.fieldsStateDic["pass"] = state
            self.continueButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToRegCredentials(segue:UIStoryboardSegue) { }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard let keyboardFrame = notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
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

extension LoginCredentialsControler: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.addSubview(toastView)
        }
    }
}
