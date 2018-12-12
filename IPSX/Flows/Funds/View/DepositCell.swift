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
        
        dateLabel.text = DateFormatter.dateStringForTokenRequests(date: Date())
        quantityLabel.text = "100"
        pendingView.isHidden   = true
        completedView.isHidden = false
        canceledView.isHidden  = true
        expiredView.isHidden   = true
    }
}
