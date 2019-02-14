//
//  LoginCredentialsControler.swift
//  IPSX
//
//  Created by Calin Chitu on 23/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class LoginCredentialsControler: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
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
    
    
    @IBOutlet weak var loginEmailTitle: UILabel!
    @IBOutlet weak var emailAddressFieldTitle: UILabel!
    @IBOutlet weak var emailAddressFieldPlaceholder: UITextField!
    @IBOutlet weak var emailAddressErrorLabel: UILabel!
    @IBOutlet weak var paswordFieldTitle: UILabel!
    @IBOutlet weak var passwordFieldPlaceholder: UITextField!
    @IBOutlet weak var passwordFieldErrorLabel: UILabel!
    @IBOutlet weak var forgotPassButton: UIButton!
    @IBOutlet weak var loginButton: RoundedButton!
    
    private func localiseStoryboard() {
        loginEmailTitle.text = "Login with Email".localized
        emailAddressFieldTitle.text = "Email Address".localized
        emailAddressFieldPlaceholder.placeholder = "Type a valid email address".localized
        emailAddressErrorLabel.text = "The email must be a valid address.".localized;
        paswordFieldTitle.text = "Password".localized
        passwordFieldPlaceholder.placeholder = "Type your password".localized
        passwordFieldErrorLabel.text = "Password incorrect label text".localized;
        forgotPassButton.setTitle("Forgot Your Password?".localized, for: .normal)
        loginButton.setTitle("Login".localized, for: .normal)
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
        
        loadingView?.startAnimating()
        LoginService().login(email: emailRichTextView.contentTextField?.text, password: passRichTextField.contentTextField?.text, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.continueFlow()
                
            case .failure(let error):
                
                let completionError: ((String) -> ()) = { [weak self] errorMessage in
                    self?.errorMessage = errorMessage
                }
                self.handleError(error, requestType: RequestType.login, completionError: completionError)
            }
        })
    }
    
    func continueFlow() {
        
        loadingView?.startAnimating()
        UserInfoService().retrieveETHaddresses(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(let ethAddresses):
                UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "UnwindToLoadingView", sender: nil)
                }
            case .failure(let error):
                
                let completionError: ((String) -> ()) = { [weak self] errorMessage in
                    self?.errorMessage = errorMessage
                }
                self.handleError(error, requestType: RequestType.getEthAddress, completionError: completionError)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueBottomDist = bottomContinueConstraint.constant
        backButton.isHidden = hideBackButton
        observreFieldsState()
        localiseStoryboard()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        backgroundImageView.removeParticlesAnimation()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
   }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
        setupTextViews()
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ForgotPasswordSegueID" {
            let nextController = segue.destination as? ForgotPassController
            nextController?.noLandingScreen = backButton.isHidden
        }
    }
    

    private func setupTextViews() {
        emailRichTextView.validationRegex       = RichTextFieldView.validEmailRegex
        emailRichTextView.nextResponderField    = passRichTextField.contentTextField
        passRichTextField.validationRegex       = RichTextFieldView.minOneCharRegex
    }
    
    private func observreFieldsState() {
        emailRichTextView.onFieldStateChange = { [weak self] state in
            
            guard let weakSelf = self else { return }
            weakSelf.fieldsStateDic["email"] = state
            weakSelf.continueButton.isEnabled = !weakSelf.fieldsStateDic.values.contains(false)
        }
        passRichTextField.onFieldStateChange = { [weak self] state in
            
            guard let weakSelf = self else { return }
            weakSelf.fieldsStateDic["pass"] = state
            weakSelf.continueButton.isEnabled = !weakSelf.fieldsStateDic.values.contains(false)
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

extension LoginCredentialsControler: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension LoginCredentialsControler: ErrorPresentable {}

