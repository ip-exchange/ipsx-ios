//
//  DepositCell.swift
//  IPSX
//
//  Created by Calin Chitu on 10/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DepositCell: UITableViewCell {
    
    static let cellID = "DepositCellID"
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    @IBOutlet weak var canceledView: RoundedView!
    @IBOutlet weak var expiredView: RoundedView!
    
    func configure(deposit: Deposit) {
        
        if let createdDate = deposit.createdAt {
            dateLabel.text = DateFormatter.dateStringForTokenRequests(date: createdDate)
        }
        
        let amount =  deposit.amount
        quantityLabel.text = amount + " IPSX"
        pendingView.isHidden   = deposit.status != "pending"
        completedView.isHidden = deposit.status != "completed"
        canceledView.isHidden  = deposit.status != "canceled"
        expiredView.isHidden   = deposit.status != "expired"
    }
}

