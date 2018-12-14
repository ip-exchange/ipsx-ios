//
//  RefundCell.swift
//  IPSX
//
//  Created by Calin Chitu on 10/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class RefundCell: UITableViewCell {
    
    static let cellID = "RefundCellID"
    
    @IBOutlet weak var refundNbLabel: UILabel!
    @IBOutlet weak var refundIssuedBylabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    @IBOutlet weak var canceledView: RoundedView!
    
    func configure(refund: Refund) {
        
        if let createdDate = refund.createdAt {
            dateLabel.text = DateFormatter.dateStringForTokenRequests(date: createdDate)
        }
        refundNbLabel.text = "Refund #" + "\(refund.id)"
        let amount = refund.value
        quantityLabel.text = amount + " IPSX"
        pendingView.isHidden   = refund.status != "pending"
        completedView.isHidden = refund.status != "completed"
        canceledView.isHidden  = refund.status != "rejected"
        
        if refund.issuedByUser {
            refundIssuedBylabel.text = "You".localized 
        }
        else {
            refundIssuedBylabel.text = "Admin".localized
        }
    }
}
