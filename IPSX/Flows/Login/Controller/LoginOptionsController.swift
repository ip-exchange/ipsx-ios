//
//  LoginOptionsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import FacebookLogin


class LoginOptionsController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var loginSubtitle: UILabel!
    @IBOutlet weak var loginEmailButton: RoundedButton!
    @IBOutlet weak var loginFacebookButton: RoundedButton!
    
    var dict: [String : AnyObject] = [:]
    
    private func localiseStoryboard() {
        closeButton.setTitle("Close".localized, for: .normal)
        loginTitle.text = "Login".localized
        loginSubtitle.text = "Login with email or facebook".localized
        loginEmailButton.setTitle("Login with Email".localized, for: .normal)
        loginFacebookButton.setTitle("Login with Facebook".localized, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localiseStoryboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func unwindToLoginOptions(segue:UIStoryboardSegue) { }
    
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        facebookLogin()
    }
    
    func facebookLogin() {
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: { loginResult in
            
                                      switch loginResult {
                
            case .failed(_):
                self.errorMessage = "Facebook Login Error Message".localized
                
            case .cancelled:
                print("User cancelled login")
                
            case .success(_,  _, let accessToken):
                self.executeLogin(withFBtoken: accessToken.authenticationToken)
            }
        })
    }
    
    func executeLogin(withFBtoken fbToken: String) {
        
        self.loadingView?.startAnimating()
        SocialIntegrationService().facebook(requestType: RequestType.fbLogin, fbToken: fbToken, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.continueFlow()
                
            case .failure(let error):
                
                let completionError: ((String) -> ()) = { [weak self] errorMessage in
                    self?.errorMessage = errorMessage
                }
                self.handleError(error, requestType: RequestType.fbLogin, completionError: completionError)
            }
        })
    }
    
    func continueFlow() {
        
        UserInfoService().retrieveETHaddresses(completionHandler: { result in
            
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
}

extension LoginOptionsController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension LoginOptionsController: ErrorPresentable {}
