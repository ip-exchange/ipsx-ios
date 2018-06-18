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
    @IBOutlet weak var cellProgress1Bis: UIProgressView!
    @IBOutlet weak var cellProgress2: UIProgressView!
    @IBOutlet weak var cellProgress2Bis: UIProgressView!
    @IBOutlet weak var cellStatusLabel: UILabel!
    @IBOutlet weak var cellusedMBLabel: UILabel!
    @IBOutlet weak var cellNoOfMBLabel: UILabel!
    @IBOutlet weak var cellDurationLabel: UILabel!
    
    func configure(proxy: Proxy) {
        
        cellTitleLabel.text = proxy.proxyPack?.name
        cellusedMBLabel.text = proxy.proxyDetails?.usedMB 
        cellStatusLabel.textColor = proxy.isTestProxy == true ? UIColor.darkBlue : UIColor.textGrey
        
        if proxy.isTestProxy && UserManager.shared.hasTestProxyAvailable {
            cellStatusLabel.text = "Test Proxy Message".localized
        }
        else {
            cellStatusLabel.text = proxy.proxyDetails?.status
        }
    
        let noOfMB = proxy.proxyPack?.noOfMB ?? "N/A"
        cellNoOfMBLabel.text = "/" + noOfMB + " " + "MB"
        
        cellProgress1.progress = proxy.dataUsageProgress
        cellProgress1Bis.progress = cellProgress1.progress
        cellProgress2.progress = proxy.timeLeftProgress
        cellProgress2Bis.progress = cellProgress2.progress
        cellDurationLabel.text = proxy.proxyDetails?.remainingDuration
    }
    
}
