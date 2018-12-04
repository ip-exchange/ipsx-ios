//
//  DashboardCell.swift
//  IPSX
//
//  Created by Calin Chitu on 03/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardCell: UITableViewCell {

    @IBOutlet weak var cellContentView: RoundedView!
    @IBOutlet weak var progressView: ProgressRoundView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var offerTypeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationRemainedLabel: UILabel!
    @IBOutlet weak var trafficLabel: UILabel!
    @IBOutlet weak var trafficRemainedLabel: UILabel!
    
    @IBOutlet weak var doubleProgressView: DoubleProgressView!
    @IBOutlet weak var offerStateView: CellStateRoundedView!
    
    func configure(offer: Offer, editMode: Bool = false, state: CellStateRoundedView.CellState = .active) {
        
        offerStateView.currentState = state
        
        let noOfProxies = offer.proxies.count
        let proxyTypeString = offer.proxies.first?.proxyType ?? "N/A"
        let ipTypeString = offer.proxies.first?.ipType ?? "N/A"
        let countryString = offer.proxies.first?.countryName ?? ""
        let sla = slaToDisplay(proxies: offer.proxies)
        
        trafficLabel.text = offer.trafficMB + " MB"
        durationLabel.text = offer.durationMin.daysHoursMinutesFormated()
        progressView.progress = Double(sla)
        progressLabel.text = "\(sla)%"
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
    
    private func slaToDisplay(proxies: [Proxy]) -> Int {
        
        var slaTotal: Int = 0
        for proxy in proxies {
            slaTotal += proxy.sla
        }
        return slaTotal / proxies.count
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
