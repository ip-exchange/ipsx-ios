//
//  GenerateAddressController.swift
//  IPSX
//
//  Created by Calin Chitu on 06/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class GenerateAddressController: UIViewController {

    @IBOutlet weak var termsOverlayView: UIView!
    @IBOutlet weak var termsOverlayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var termsOverlayBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var cartFlow = false

    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        termsOverlayView.alpha = 0
        termsOverlayTopConstraint.constant = 540
        termsOverlayBottomConstraint.constant = -460
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }

    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func createAddress(_ sender: Any) {
        updateAgreementOverlay(visible: true)
    }
    
    @IBAction func closeTermsOverlay(_ sender: Any) {
        updateAgreementOverlay(visible: false)
    }
    
    @IBAction func acceptTermsOverlay(_ sender: Any) {
        updateAgreementOverlay(visible: false)
        createWaccAdddress()
    }
    
    private func createWaccAdddress() {
        loadingView.startAnimating()
        FundsService().createWaccAddress(completionHandler: { result in
            DispatchQueue.main.async { self.loadingView.stopAnimating() }
            switch result {
            case .success(_):
                DispatchQueue.main.async { self.performSegue(withIdentifier: "AddressSegueID", sender: self) }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.createWaccAdddress()
                })
            }
        })
    }
    
    private func updateAgreementOverlay(visible: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.termsOverlayTopConstraint.constant = visible ? 40 : 540
            self.termsOverlayBottomConstraint.constant = visible ? 40 : -460
            self.termsOverlayView.alpha = visible ? 1 : 0
            self.view.layoutIfNeeded()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddressSegueID" {
            let destination = segue.destination as? ViewGeneratedAdrressController
            destination?.newAdrressCreated = true
            destination?.cartFlow = cartFlow
        }
    }
}

extension GenerateAddressController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension GenerateAddressController: ErrorPresentable {
    
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
