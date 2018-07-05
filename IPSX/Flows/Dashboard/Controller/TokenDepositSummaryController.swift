//
//  TokenDepositSummaryController.swift
//  IPSX
//
//  Created by Calin Chitu on 04/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class TokenDepositSummaryController: UIViewController {
    
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var ethDepositAddressLabel: UILabel!
    @IBOutlet weak var ethAddresAlias: UILabel!
    @IBOutlet weak var ethAddress: UILabel!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    @IBOutlet weak var detailsTitleLabel: UILabel!
    @IBOutlet weak var detailsAmountLabel: UILabel!
    @IBOutlet weak var detailsRemainingTimeLabel: UILabel!
    @IBOutlet weak var detailsStateCanceledView: RoundedView!
    @IBOutlet weak var detailsStatePendingView: RoundedView!
    @IBOutlet weak var detailsStateCompletedView: RoundedView!
    @IBOutlet weak var backButton: UIButton!
    
    //TODO (CVI): This is visible only if status is pending
    @IBOutlet weak var cancelDeposit: UIButton!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var presentedFromCreateScreen = false
    
    var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }

    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelDepositAction(_ sender: Any) {
        //TODO (CVI): magic happens here :)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    private func updateUI() {
        //TODO (CVI): Update with datasource items
        backButton.isHidden = presentedFromCreateScreen
    }

}

extension TokenDepositSummaryController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}
