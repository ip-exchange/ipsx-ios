//
//  ViewGeneratedAdrressController.swift
//  IPSX
//
//  Created by Calin Chitu on 06/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ViewGeneratedAdrressController: UIViewController {

    @IBOutlet weak var addressLinkLabel: UILabel!
    @IBOutlet weak var copyLinkButton: RoundedButton!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    var newAdrressCreated = false
    var cartFlow = false
    var shouldDismiss = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    @IBAction func copyLinkAction(_ sender: Any) {
        UIPasteboard.general.string = addressLinkLabel.text
        toast?.showToastAlert("ETH Address Copied Message".localized, autoHideAfter: 5, type: .info, dismissable: true)
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
