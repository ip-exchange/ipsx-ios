//
//  DashboardHeaderCell.swift
//  IPSX
//
//  Created by Calin Chitu on 03/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardHeaderCell: UITableViewCell {

    @IBOutlet weak var orderNumberLabel: UILabel?
    @IBOutlet weak var historyTitleLabel: UILabel?
    @IBOutlet weak var labelesTopConstraint: NSLayoutConstraint?
    
    @IBAction func headerTap(_ sender: Any) {
        onTap?(section)
    }
    
    var onTap: ((_ : Int)->())?
    
    private var section: Int = 0
    
    func updateCell(sectionIndex: Int, historyTitle: String = "") {
        section = sectionIndex
        historyTitleLabel?.text = historyTitle
    }
}
