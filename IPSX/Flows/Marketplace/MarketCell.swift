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
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var offerTypeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var priceIPSXLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trafficLabel: UILabel!
    
    func configure(offer: Offer) {
        
        let noOfProxies = offer.proxies.count
        let proxyTypeString = offer.proxies.first?.proxyType ?? "N/A"
        let ipTypeString = offer.proxies.first?.ipType ?? "N/A"
        let countryString = offer.proxies.first?.countryName ?? ""
        let sla = slaToDisplay(proxies: offer.proxies)
            
        trafficLabel.text = offer.trafficMB + " MB"
        durationLabel.text = offer.durationMin.daysHoursMinutesFormated()
        priceIPSXLabel.text = offer.priceIPSX
        
        let progress = Double(arc4random_uniform(sla))
        progressView.progress = progress
        progressLabel.text = "\(Int(progress))%"
        
        cellContentView.shadow = true
        
        if noOfProxies > 1 {
            flagImageView.image = UIImage(named: "worldPins")
            offerTypeLabel.text = "Grouped offer".localized
            countryLabel.text = ""
        }
        else {
            flagImageView.image = UIImage(named: "RO32") //TODO
            offerTypeLabel.text = "\(noOfProxies)" + "IP-" + proxyTypeString + "-" + ipTypeString
            countryLabel.text = countryString
        }
    }
    
    private func slaToDisplay(proxies: [Proxy]) -> UInt32 {
        
        var slaTotal: UInt32 = 0
        for proxy in proxies {
            let intValue = UInt32(proxy.sla) ?? 0
            slaTotal += intValue
        }
        return slaTotal / UInt32(proxies.count)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
