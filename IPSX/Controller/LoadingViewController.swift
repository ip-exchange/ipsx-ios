//
//  LoadingViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 15/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var loadingBottomLabel: UILabel!
    @IBOutlet weak var toastHolderView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    let dispatchGroup = DispatchGroup()
    var hasPerformedAutologin = false
    var hasConfirmedDeleteAccount = false
    
    // Update this when adding more requests
    var noOfRequests: Float = 9
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: toastHolderView, text: "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
        
        if !ReachabilityManager.shared.isReachable() {
            toast?.showToastAlert("No internet connection".localized, dismissable: false)
            loadingBottomLabel.text = "Connect to the internet message".localized
        }
        else {
            loadingBottomLabel.text = "Loading message".localized
            continueFlow()
        }
    }
    
    func continueFlow() {
        if UserManager.shared.isLoggedIn {
            initDataAndContinueFlow()
        }
        else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "TabbarSegueID", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TabbarSegueID" {
            let destinationVC = segue.destination as? TabBarViewController
            destinationVC?.hasPerformedAutologin = hasPerformedAutologin
            destinationVC?.hasConfirmedDeleteAccount = hasConfirmedDeleteAccount
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundImageView.removeParticlesAnimation()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.loadingBottomLabel.text = "Connect to the internet message".localized
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else {
                if self.toast?.currentText == "No internet connection".localized {
                    self.toast?.hideToastAlert()
                }
                self.loadingBottomLabel.text = "Loading message".localized
                self.continueFlow()
            }
        }
    }
    
    func initDataAndContinueFlow() {
        
        userCountryList()
        ethAddresses()
        companyDetails()
        userInfo()
        userRoles()
        tokenRequestList()
        proxyCountryList()
        generalSettings()
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "TabbarSegueID", sender: self)
            }
        }
    }
    
    func userCountryList() {
        
        dispatchGroup.enter()
        UserInfoService().getUserCountryList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            switch result {
            case .success(let countryList):
                UserManager.shared.userCountries = countryList as? [[String: String]]
                DispatchQueue.main.async { self.progressView.progress += 1 / self.noOfRequests }
            case .failure(_):
                print("Generic Error Message".localized)
            }
        })
    }
    
    func ethAddresses() {
        
        dispatchGroup.enter()
        UserInfoService().retrieveETHaddresses(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let ethAddresses):
                UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                DispatchQueue.main.async { self.progressView.progress += 1 / self.noOfRequests }

            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getEthAddress, completion: {
                    self.ethAddresses()
                })
            }
        })
    }
    
    func companyDetails() {
        
        dispatchGroup.enter()
        LegalPersonService().getCompanyDetails(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let company):
                UserManager.shared.company = company as? Company
                DispatchQueue.main.async { self.progressView.progress += 1 / self.noOfRequests }
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getCompany, completion: {
                    self.companyDetails()
                })
            }
        })
    }
    
    func providerDetails() {
        
        dispatchGroup.enter()
        ProviderService().getProviderStatus(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let status):
                UserManager.shared.providerSubmissionStatus = status as? ProviderStatus
                DispatchQueue.main.async { self.progressView.progress += 1 / self.noOfRequests }
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getProviderDetails, completion: {
                    self.providerDetails()
                })
            }
        })
    }
    
    func userInfo() {
        
        dispatchGroup.enter()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                DispatchQueue.main.async { self.progressView.progress += 1 / self.noOfRequests }

            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.userInfo()
                })
            }
        })
    }
    
    func userRoles() {
        
        dispatchGroup.enter()
        UserInfoService().getRoles(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let userRoles):
                UserManager.shared.roles = userRoles as? [UserRoles]
                DispatchQueue.main.async { self.progressView.progress += 1 / self.noOfRequests }
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.userRoles, completion: {
                    self.userRoles()
                })
            }
        })
    }
    
    func tokenRequestList() {
        
        dispatchGroup.enter()
        TokenDepositService().getTokenRequestList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let tokenRequests):
                UserManager.shared.tokenRequests = tokenRequests as? [TokenRequest]
                DispatchQueue.main.async { self.progressView.progress += 1 / self.noOfRequests }

            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getTokenRequestList, completion: {
                    self.tokenRequestList()
                })
            }
        })
    }
    
    func proxyCountryList() {
        
        dispatchGroup.enter()
        ProxyService().getProxyCountryList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let countryList):
                UserManager.shared.proxyCountries = countryList as? [String]
                DispatchQueue.main.async { self.progressView.progress +=  1 / self.noOfRequests }

            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getProxyCountryList, completion: {
                    self.proxyCountryList()
                })
            }
        })
    }
    
    func generalSettings() {
        
        dispatchGroup.enter()
        SettingsService().retrieveSettings(completionHandler: { result in
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let settings):
                UserManager.shared.generalSettings = settings as? GeneralSettings
                DispatchQueue.main.async { self.progressView.progress +=  1 / self.noOfRequests }
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.generalSettings, completion: {
                    self.generalSettings()
                })
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoadingViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.addSubview(toastView)
        }
    }
}

extension LoadingViewController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                print("Generic Error Message".localized)
                
            }, successHandler: {
                completion?()
            })
        default:
            print("Generic Error Message".localized)
        }
    }
}
