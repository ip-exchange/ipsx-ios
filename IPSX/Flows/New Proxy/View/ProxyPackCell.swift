//
//  ProxyPackCell.swift
//  IPSX
//
//  Created by Cristina Virlan on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProxyPackCell: UITableViewCell {
    
    @IBOutlet weak var cellContentView: RoundedView!
    @IBOutlet weak var packImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var noOfMBLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configure(proxyPack: ProxyPack) {
        
        packImageView.image = UIImage(named: proxyPack.iconName)
        nameLabel.text = proxyPack.name
        noOfMBLabel.text = "\(proxyPack.noOfMB)" + "MB"
        if let minDuration = Int(proxyPack.duration) {
            let components = DateFormatter.secondsToDaysHoursMinutes(seconds: minDuration * 60)
            durationLabel.text = DateFormatter.readableDaysHoursMinutes(components:components)
        } else {
            durationLabel.text = "0 min"
        }
        priceLabel.text = "\(proxyPack.price)" + " " + "IPSX"
    }
}
