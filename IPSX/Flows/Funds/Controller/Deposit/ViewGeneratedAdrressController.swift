//
//  ViewGeneratedAdrressController.swift
//  IPSX
//
//  Created by Calin Chitu on 06/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class ViewGeneratedAdrressController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var addressLinkLabel: UILabel!
    @IBOutlet weak var copyLinkButton: RoundedButton!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    @IBOutlet weak var buyTokensButton: RoundedButton!
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }

    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    var newAdrressCreated = false
    var cartFlow = false
    var shouldDismiss = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLinkLabel.text = "---"
        if UserManager.shared.environment == .dev {
            buyTokensButton.setTitle("Request Tokens".localized, for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if addressLinkLabel.text == "---" { retrieveWaccAddress() }
        if newAdrressCreated {
            toast?.showToastAlert("Your wallet address was successfully created!".localized, autoHideAfter: 5, type: .info, dismissable: true)
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        guard !shouldDismiss else {
            dismiss(animated: true)
            return
        }
        let identifier = cartFlow ? "unwindToMarketItem" : "unwindToDepositListSegue"
        DispatchQueue.main.async { self.performSegue(withIdentifier: identifier, sender: self) }
    }
    
    @IBAction func tokenBuyOrRequest(_ sender: Any) {
        if UserManager.shared.environment == .dev {
            DispatchQueue.main.async { self.performSegue(withIdentifier: "TokenrequestSegueID", sender: self) }
            
        } else {
            //TODO: Buy from Cryptocoin
        }
    }
    
    @IBAction func copyLinkAction(_ sender: Any) {
        UIPasteboard.general.string = addressLinkLabel.text
        toast?.showToastAlert("ETH Address Copied Message".localized, autoHideAfter: 5, type: .info, dismissable: true)
    }
    
    @IBAction func unwindToWiewGeneratedAddress(segue:UIStoryboardSegue) {}
    
    private func retrieveWaccAddress() {
        self.addressLinkLabel.text = "Retrieving the address...".localized
        loadingView.startAnimating()
        FundsService().retrieveWaccAddress(completionHandler: { result in
            DispatchQueue.main.async { self.loadingView.stopAnimating() }
            switch result {
            case .success(let address):
                DispatchQueue.main.async { self.addressLinkLabel.text = address as? String ?? "---" }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.retrieveWaccAddress()
                })
            }
        })
    }

}

extension ViewGeneratedAdrressController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension ViewGeneratedAdrressController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
            
        default:
            
            switch requestType {
            case RequestType.userInfo, RequestType.getEthAddress:
                self.errorMessage = "Refresh Data Error Message".localized
            case RequestType.deleteEthAddress:
                self.errorMessage = "ETH Address Delete Failed Error Message".localized
            default:
                self.errorMessage = "Generic Error Message".localized
            }
        }
    }
}
