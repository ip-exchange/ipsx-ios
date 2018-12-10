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
    @IBOutlet weak var expiredView: RoundedView!
    
    func configure() {
        dateLabel.text = DateFormatter.dateStringForTokenRequests(date: Date())
        quantityLabel.text = "100"
        pendingView.isHidden   = true
        completedView.isHidden = true
        canceledView.isHidden  = false
        expiredView.isHidden   = true
    }
}
