//
//  RefundDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 17/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class RefundDetailsController: UIViewController {

    @IBOutlet weak var refundTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var adminResponseTextView: UITextView!
    @IBOutlet weak var issuedByLabel: UILabel!
    @IBOutlet weak var proxyNumber: UILabel!
   
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    @IBOutlet weak var canceledView: RoundedView!
    @IBOutlet weak var viewProxyButton: UIButton!
    
    var refund: Refund?
    var hideProxButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewProxyButton.isHidden = hideProxButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func updateUI() {
        
        guard let refund = refund else { return }
        
        
        let refundNb = refund.id
        refundTitleLabel.text = "Refund".localized + " #\(refundNb)"
        amountLabel.text = refund.value
        
        if let createdDate = refund.createdAt {
            dateLabel.text = DateFormatter.dateStringForTokenRequests(date: createdDate)
        }
        issuedByLabel.text = refund.issuedByUser ? "You".localized : "Admin".localized
        proxyNumber.text = "#\(refund.proxyId)"
        
        reasonTextView.text = refund.userReason.count > 0 ? refund.userReason : "No reason".localized
        adminResponseTextView.text = refund.adminReason.count > 0 ? refund.adminReason : "No reason".localized
        
        pendingView.isHidden   = refund.status != "pending"
        completedView.isHidden = refund.status != "completed"
        canceledView.isHidden  = refund.status != "rejected"

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewProxySegue" {
            let dest = segue.destination as? DashboardDetailsController
            dest?.shouldDismiss = true
            dest?.orderOfferProxyId = refund?.proxyId 
        }
    }
}
