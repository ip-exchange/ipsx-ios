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
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var offerTypeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var offerStateView: CellStateRoundedView!
    @IBOutlet weak var expiredCountLabel: UILabel!
    
    func configure(offer: Offer, editMode: Bool = false, state: CellStateRoundedView.CellState = .pending) {
        
        let noOfProxies = offer.proxies.count
        let proxyTypeString = offer.proxies.first?.proxyType ?? "N/A"
        let ipTypeString = offer.proxies.first?.ipType ?? "N/A"
        let countryString = offer.proxies.first?.countryName ?? ""
        
        cellContentView.shadow = true
        flagImageView.image = UIImage(named: "worldPins")
        
        if noOfProxies == 1 {
            offerTypeLabel.text = "\(noOfProxies)" + "IP-" + proxyTypeString + "-" + ipTypeString
            countryLabel.text = countryString
            
            if let flagString = offer.proxies.first?.flagUrlName,
                let flagUrl = URL(string: flagString),
                let flagImage = UIImage(named: flagUrl.deletingPathExtension().lastPathComponent) {
                flagImageView.image = flagImage
            }
        }
        
        var index: Int   = 0
        var expired: Int = 0
        var countries: [String] = []
        for proxy in offer.proxies {
            if !countries.contains(proxy.countryName) {
                countries.append(proxy.countryName)
            }
            if index == 0 {
                offerStateView.setActiveState(proxy.status)
            } else {
                if proxy.status == "active" { offerStateView.setActiveState(proxy.status) }
                offerTypeLabel.text = "Grouped offer".localized
            }
            if proxy.status == "expired" { expired += 1}
            index += 1
        }
        let firstCountry = countries.first ?? "Unknown"
        if index > 1 { countryLabel.text = firstCountry + " " + "and \(countries.count - 1) more".localized }
        expiredCountLabel.text = "\(expired)/\(index) " + "EXPIRED".localized
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
