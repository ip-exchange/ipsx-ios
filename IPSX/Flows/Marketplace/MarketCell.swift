//
//  MarketCell.swift
//  IPSX
//
//  Created by Calin Chitu on 15/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class MarketCell: UITableViewCell {

    @IBOutlet weak var cellContentView: RoundedView!
    @IBOutlet weak var progressView: ProgressRoundView!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
