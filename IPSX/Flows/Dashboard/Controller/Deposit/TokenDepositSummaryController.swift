//
//  TokenDepositSummaryController.swift
//  IPSX
//
//  Created by Calin Chitu on 04/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import CVINetworkingFramework

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
    @IBOutlet weak var initialRequestedAmountLabel: UILabel!
    
    @IBOutlet weak var detailsStateCanceledView: RoundedView!
    @IBOutlet weak var detailsStatePendingView: RoundedView!
    @IBOutlet weak var detailsStateCompletedView: RoundedView!
    @IBOutlet weak var detailsStateExpiredView: RoundedView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cancelDepositButton: UIButton!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }

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
    
    @IBAction func copyDepositAddressAction(_ sender: Any) {
        if let depositAddress = ethDepositAddressLabel.text {
            UIPasteboard.general.string = depositAddress
            let depositCopiedMessage = String(format: "%@ copied to cplipboard".localized, "\(depositAddress)")
            self.toast?.hideToastAlert() {
                self.toast?.showToastAlert(depositCopiedMessage, type: .info)
            }
        }
    }
    
    @IBAction func cancelDepositAction(_ sender: Any) {
        cancelDeposit()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if presentedFromCreateScreen {
            let amount = deposit?.amountRequested ?? "N/A"
            
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
        cancelDepositButton.isHidden = deposit?.status != "pending"
        
        detailsStatePendingView.isHidden   = deposit?.status != "pending"
        detailsStateCompletedView.isHidden = deposit?.status != "complete"
        detailsStateCanceledView.isHidden  = deposit?.status != "canceled"
        detailsStateExpiredView.isHidden   = deposit?.status != "expired"
        
        ethDepositAddressLabel.text = UserManager.shared.generalSettings?.depositEthAddress
        
        let ethAddress = UserManager.shared.ethAddres(forID: deposit?.ethID ?? 0)
        ethAddressLabel.text = ethAddress?.address
        ethAddresAlias.text = ethAddress?.alias
        
        let amountRequested = deposit?.amountRequested ?? "-"
        let amountReceived = deposit?.amountReceived ?? "-"
        let amount = deposit?.status == "complete" ? amountReceived : amountRequested
        
        initialRequestedAmountLabel.isHidden = amountRequested == amountReceived || deposit?.status != "complete"
        
        initialRequestedAmountLabel.text = "Requested".localized + ": " + amountRequested + " IPSX"
        detailsTitleLabel.text = amount + " IPSX"
        detailsAmountLabel.text = deposit?.status == "complete" ? "Received".localized : "Requested".localized
        
        if let watchUntilDate = deposit?.watchUntil, let createdAtDate = deposit?.createdAt {
            if deposit?.status == "pending" {
                
                if watchUntilDate.timeIntervalSince(Date()) > 0 {
                    let remainingDuration = watchUntilDate.timeIntervalSince(Date())
                    let components = DateFormatter.secondsToDaysHoursMinutes(seconds: Int(remainingDuration))
                    let remainigDuartionString = DateFormatter.readableDaysHoursMinutes(components:components)
                    detailsRemainingTimeLabel.text = String(format: "Time Remaining %@".localized, "\(remainigDuartionString)")
                } else {
                    detailsRemainingTimeLabel.text = String(format: "Time Remaining %@ min".localized, "\(0)")
                }
            } else {
                detailsRemainingTimeLabel.text = DateFormatter.dateStringForTokenRequests(date: createdAtDate)
            }
            
        } else {
            detailsRemainingTimeLabel.text = String(format: "Time Remaining %@ min".localized, "\(0)")
        }

    }
    
    func cancelDeposit() {

        loadingView?.startAnimating()
        TokenDepositService().cancelDeposit(depositID: deposit?.depositID ?? 0, completionHandler: { result in
            self.loadingView?.stopAnimating()
            switch result {

            case .success(_):

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showTokenDepositList", sender: nil)
                }

            case .failure(let error):

                self.handleError(error, requestType: IPRequestType.cancelDeposit, completion: {
                    self.cancelDeposit()
                })
            }
        })
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

extension TokenDepositSummaryController: ErrorPresentable {
    
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
