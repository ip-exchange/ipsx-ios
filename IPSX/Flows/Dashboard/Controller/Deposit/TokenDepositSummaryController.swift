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
    @IBOutlet weak var ethAddressLabel: UILabel!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var detailsTitleLabel: UILabel!
    @IBOutlet weak var detailsAmountLabel: UILabel!
    @IBOutlet weak var detailsRemainingTimeLabel: UILabel!
    @IBOutlet weak var detailsStateCanceledView: RoundedView!
    @IBOutlet weak var detailsStatePendingView: RoundedView!
    @IBOutlet weak var detailsStateCompletedView: RoundedView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }

    //TODO (CVI): This is visible only if status is pending
    @IBOutlet weak var cancelDeposit: UIButton!
    
    //TODO (CC): add Copy button for payment address
    
    var deposit: Deposit?
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if presentedFromCreateScreen {
            let amount = deposit?.amount ?? "N/A"
            
            //TODO (CC): change format to display 2018-07-08 16:36:35 UTC
            let expirationDate = deposit?.watchUntil?.dateToString(format: "dd MMM yyyy") ?? "N/A"
            
            let depositCreatedMessage = String(format: "Token Deposit Created %@ IPSX expiration date %@ Message".localized, "\(amount)", "\(expirationDate)")
            toast?.showToastAlert(depositCreatedMessage, type: .info)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    private func updateUI() {
        
        backButton.isHidden = presentedFromCreateScreen
        cancelDeposit.isHidden = deposit?.status != "pending"
        
        detailsStatePendingView.isHidden   = deposit?.status != "pending"
        detailsStateCompletedView.isHidden = deposit?.status != "completed"
        detailsStateCanceledView.isHidden  = deposit?.status != "rejected"
        
        let ethAddress = UserManager.shared.ethAddres(forID: deposit?.ethID ?? 0)
        ethAddressLabel.text = ethAddress?.address
        ethAddresAlias.text = ethAddress?.alias
        
        let amount = deposit?.amount ?? "-"
        detailsAmountLabel.text = amount + " IPSX"
        
        //TODO (CC): format expirationDate to display "11 min" / "1 h 10 min / ..."
        let expirationDate = deposit?.watchUntil?.dateToString(format: "dd MMM yyyy") ?? "N/A"
        
        //TODO (CC): fix autolayout for detailsRemainingTimeLabel (text truncated)
        detailsRemainingTimeLabel.text = String(format: "Time Remaining %@".localized, "\(expirationDate)")
        
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
