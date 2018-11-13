//
//  WalletViewerController.swift
//  IPSX
//
//  Created by Calin Chitu on 13/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class WalletViewerController: UIViewController {

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var topSeparatorConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint = topSeparatorConstraint
        }
    }
    
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletDateLabel: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    
    @IBOutlet weak var lockedStateHolderView: UIView!
    @IBOutlet weak var approveStateHolderView: UIView!
    @IBOutlet weak var approveStateImageView: UIImageView!
    @IBOutlet weak var approveStateLabel: UILabel!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    var ethereumAddress: EthAddress?
    
    private var updatedAlias: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ethereumAddress?.status != "locked" {
            lockedStateHolderView.isHidden = true
            approveStateHolderView.frame.origin.x -= lockedStateHolderView.frame.size.width / 2
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    @IBAction func copyAddrAction(_ sender: Any) {
        if let address = ethereumAddress?.address {
            UIPasteboard.general.string = address
            toast?.showToastAlert("ETH Address Copied Message".localized, autoHideAfter: 5, type: .info, dismissable: true)
        }
    }
    
    @IBAction func buyFormCCoinAction(_ sender: Any) {
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func updateUI() {
        
        guard let ethAddress = ethereumAddress else { return }
        
        walletNameLabel.text = ethAddress.alias
        walletAddress.text   = ethAddress.address
        let formattedDate    = ethAddress.createdDate?.dateToString(format: "dd MMM yyyy") ?? "--/--/---"
        walletDateLabel.text = "Created at: ".localized + formattedDate
        
        switch ethAddress.validationState {
        case .verified:
            approveStateImageView.image = UIImage(named: "decoApproved")
            approveStateLabel.text      = "Approved".localized
        case .pending:
            approveStateImageView.image = UIImage(named: "decoPending")
            approveStateLabel.text      = "Pending".localized
        case .rejected:
            approveStateImageView.image = UIImage(named: "decoRejected")
            approveStateLabel.text      = "Rejected".localized
        }
        
        if let alias = updatedAlias {
            walletNameLabel.text = alias
            updatedAlias = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editController = segue.destination as? WalletAddController
        editController?.ethereumAddress = ethereumAddress
        editController?.onAddressEdited = { alias in
            self.ethereumAddress?.alias = alias
            self.updatedAlias = alias
        }
    }

}

extension WalletViewerController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}
