//
//  WithdrawallCell.swift
//  IPSX
//
//  Created by Calin Chitu on 10/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class WithdrawallCell: UITableViewCell {
    
    static let cellID = "WithdrawallCellID"
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    @IBOutlet weak var canceledView: RoundedView!
    @IBOutlet weak var expiredView: RoundedView!
    
    func configure(withdrawal: Withdrawal) {
        
        if let createdDate = withdrawal.createdAt {
            dateLabel.text = DateFormatter.dateStringForTokenRequests(date: createdDate)
        }
        
        let amount =  withdrawal.amount
        quantityLabel.text = amount + " IPSX"
        pendingView.isHidden   = withdrawal.status != "pending"
        completedView.isHidden = withdrawal.status != "completed"
        canceledView.isHidden  = withdrawal.status != "canceled"
        expiredView.isHidden   = withdrawal.status != "expired"
    }
}
