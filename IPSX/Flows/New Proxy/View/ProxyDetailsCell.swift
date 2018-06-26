//
//  ProxyDetailsCell.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProxyDetailsCell: UITableViewCell {
    
    static let cellID = "ProxyDetailsCellD"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var copyLabel: UILabel?
    
    func configure(title: String? = nil, value: String? = nil, additionalDetail: String? = nil, allowCopy: Bool = true) {
        
        titleLabel?.text = title
        valueLabel?.text = value
        detailLabel?.text = additionalDetail
        copyLabel?.isHidden = !allowCopy
    }
}
