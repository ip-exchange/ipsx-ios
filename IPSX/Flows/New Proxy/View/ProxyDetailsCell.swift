//
//  ProxyDetailsCell.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProxyDetailsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func configure(title: String? = nil, value: String? = nil, additionalDetail: String? = nil) {
        
        titleLabel?.text = title
        valueLabel?.text = value
        detailLabel?.text = additionalDetail
    }
}
