//
//  ProxyActivationDetailsCell.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProxyActivationDetailsCell: UITableViewCell {
    
    @IBOutlet weak var cellContentView: RoundedView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellProgress1: UIProgressView!
    @IBOutlet weak var cellProgress2: UIProgressView!
    @IBOutlet weak var cellStatusLabel: UILabel!
    @IBOutlet weak var cellRemainingMBLabel: UILabel!
    @IBOutlet weak var cellNoOfMBLabel: UILabel!
    @IBOutlet weak var cellDurationLabel: UILabel!
    
    func configure(proxy: Proxy) {
        
        cellTitleLabel.text = proxy.proxyPack?.name
        cellStatusLabel.text = proxy.proxyDetails?.status
        
        let remainingMB = proxy.proxyDetails?.remainingMB ?? 0
        cellRemainingMBLabel.text = "\(remainingMB)"
        
        let noOfMB = proxy.proxyPack?.noOfMB ?? 0
        cellNoOfMBLabel.text = "/" + "\(noOfMB)" + " " + "MB"
        cellDurationLabel.text = proxy.proxyPack?.duration
    }
    
}
