//
//  MarketCheckoutController.swift
//  IPSX
//
//  Created by Calin Chitu on 22/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class MarketCheckoutController: UIViewController {

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var topSeparatorConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint = topSeparatorConstraint
        }
    }
    @IBOutlet weak var loadingView: CustomLoadingView!
    
    @IBOutlet weak var activationInfoAttributedLabel: UILabel!
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    private let unwindToMarketSegueID = "UnwindToMarketSegueID"
    
    @IBOutlet weak var lockedIPLabel: UILabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var priceIPSXLabel: UILabel!
    @IBOutlet weak var priceUSDLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedString = NSMutableAttributedString(string: "The proxies will be activated in \nmaximum 5 minutes after purchase!", attributes: [
            .font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            .foregroundColor: UIColor(white: 153.0 / 255.0, alpha: 1.0)
            ])
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14.0, weight: .bold), range: NSRange(location: 34, length: 17))
        activationInfoAttributedLabel.attributedText = attributedString
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }

    @IBAction func rentAction(_ sender: Any) {
        self.performSegue(withIdentifier: unwindToMarketSegueID, sender: self)
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}


extension MarketCheckoutController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension MarketCheckoutController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}
