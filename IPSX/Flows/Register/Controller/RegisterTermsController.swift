//
//  RegTermsConntroller.swift
//  IPSX
//
//  Created by Calin Chitu on 20/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class RegisterTermsController: UIViewController {

    @IBOutlet weak var individualCheckButton: UIButton!
    @IBOutlet weak var companyCheckButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var registerButton: RoundedButton!
    @IBOutlet weak var companySelectorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var fbToken: String = ""
    var newsletter: Bool = true
    var userType: UserType = .individual
    var isFbFlow = false
    
    private var statesDic: [String : Bool] = [:]
    var userCredentials: [String: String] = ["email": "", "pass": "", "country_id": ""]
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func termsAndConditionsAction(_ sender: Any) {
        performSegue(withIdentifier: "TermsWebViewSegueID", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "TermsWebViewSegueID":
            let destinationWebController = segue.destination as? SimpleWebView
            destinationWebController?.loadingURLString = Url.termsUrl
            destinationWebController?.titleString = "T&C".localized
            
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.isEnabled = false
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
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        configureUI()
     }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundImageView.removeParticlesAnimation()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
    }
    
    func configureUI() {
        
        isFbFlow = fbToken != ""
        
        if isFbFlow {
            companySelectorView.isHidden = true
            individualCheckButton.isSelected = false
            individualCheckButton.isEnabled = false
        }
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

    @IBAction func checkboxButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let titleText = sender.title(for: .selected) {
            statesDic[titleText] = sender.isSelected
        }
        var allAgreed = true
        if statesDic.values.contains(false) {
            allAgreed = false
        }
        registerButton.isEnabled = allAgreed
    }
    
    @IBAction func newsletterButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        newsletter = sender.isSelected
    }
    
    @IBAction func registerButtonAction(_ sender: UIButton) {
        
        loadingView?.startAnimating()
        IPService().getPublicIPAddress(completion: { error, ipAddress in
            
            self.loadingView?.stopAnimating()
            guard let ipAddress = ipAddress, error == nil else {

                self.errorMessage = "Generic Error Message".localized
                return
            }
            self.register(ipAddress: ipAddress)
        })
    }
    
    @IBAction func individualCheckAction(_ sender: UIButton) {
        sender.isSelected = true
        companyCheckButton.isSelected = false
        userType = .individual
    }
    
    @IBAction func companyCheckAction(_ sender: UIButton) {
        sender.isSelected = true
        individualCheckButton.isSelected = false
        userType = .company
    }
    
    func register(ipAddress: String) {
        
        if isFbFlow, let countryID = self.userCredentials["country_id"] {
            self.registerWithFacebook(fbToken: fbToken, countryID: countryID)
        }
        else if let email = self.userCredentials["email"], let pass = self.userCredentials["pass"], let countryID = self.userCredentials["country_id"] {
            self.registerWithEmailPass(email: email, pass: pass, ipAddress: ipAddress, countryID: countryID)
        }
        else {
            self.loadingView?.stopAnimating()
            self.errorMessage = "Generic Error Message".localized
        }
    }
    
    func registerWithFacebook(fbToken: String, countryID: String) {
        
        self.loadingView?.startAnimating()
        SocialIntegrationService().facebook(requestType: RequestType.fbRegister, fbToken: fbToken, countryID: countryID, newsletter: newsletter, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.continueFlow()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.fbRegister)
            }
        })
    }
    
    func registerWithEmailPass(email: String, pass: String, ipAddress: String, countryID: String) {
        
        self.loadingView?.startAnimating()
        RegisterService().registerUser(email: email, password: pass, ip: ipAddress, countryID: countryID, newsletter: newsletter, type: userType, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.continueFlow()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.register)
            }
        })
    }
    
    func continueFlow() {
        
        DispatchQueue.main.async {
            
            if self.isFbFlow {
                self.performSegue(withIdentifier: "CongratsSegueID", sender: nil)
            }
            else {
                self.performSegue(withIdentifier: "showRegConfirmationSegueID", sender: nil)
            }
        }
    }
}

extension RegisterTermsController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

class RegisterDoneController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundImageView.removeParticlesAnimation()
    }

}

extension RegisterTermsController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch requestType {
            
        case RequestType.fbRegister, RequestType.register:
            
            switch error {
            case CustomError.alreadyExists:
                self.errorMessage = "User already registered Error Message".localized
                
            case CustomError.fbNoEmailError:
                self.errorMessage = "Facebook Register No Email Error".localized
                
            default:
                self.errorMessage = "Generic Error Message".localized
            }
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}
