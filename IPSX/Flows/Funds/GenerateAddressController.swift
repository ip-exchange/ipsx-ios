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
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

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
        //TODO: Generate address API here
    }
    
    private func updateAgreementOverlay(visible: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.termsOverlayTopConstraint.constant = visible ? 40 : 540
            self.termsOverlayBottomConstraint.constant = visible ? 40 : -460
            self.termsOverlayView.alpha = visible ? 1 : 0
            self.view.layoutIfNeeded()
        })
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
