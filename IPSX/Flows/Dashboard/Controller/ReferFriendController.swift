//
//  ReferFriendController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ReferFriendController: UIViewController {

    @IBOutlet weak var referalLinkLabel: UILabel!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        if let refCode = UserManager.shared.userInfo?.refferalCode {
            referalLinkLabel.text = Url.referalCodeUrl + refCode
            copyLinkButton.isEnabled = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }

    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func copyLinkAction(_ sender: Any) {
        UIPasteboard.general.string = referalLinkLabel.text
        toast?.showToastAlert("The refferal link has been copied, send it to your friends for register.", autoHideAfter: 5, type: .info, dismissable: true)
    }
}

extension ReferFriendController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}
