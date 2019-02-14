//
//  GenerateAddressController.swift
//  IPSX
//
//  Created by Calin Chitu on 06/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

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
                
                let completionError: ((String) -> ()) = { [weak self] errorMessage in
                    self?.errorMessage = errorMessage
                }
                let completionRetry: (() -> ()) = { [weak self] in
                    self?.createWaccAdddress()
                }
                self.handleError(error, requestType: RequestType.addWaccAddress, completionRetry: completionRetry, completionError: completionError)
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
            if cartFlow {
                destination?.shouldDismiss = false
            }
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

extension GenerateAddressController: ErrorPresentable {}
