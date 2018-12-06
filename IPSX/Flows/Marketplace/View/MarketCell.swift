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
    @IBOutlet weak var cartImageView: UIImageView!
    @IBOutlet weak var favImageView: UIImageView!
    
    @IBOutlet weak var cellLeadingConstraint: NSLayoutConstraint?
    
    public var onDelete:((_ : Offer)->())?
    private var cellOffer: Offer?
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if let offer = cellOffer { onDelete?(offer) }
    }
    
    func configure(offer: Offer, editMode: Bool = false) {
        
        cellOffer = offer
        
        cartImageView.isHidden = !offer.isAddedToCart
        favImageView.isHidden = !offer.isFavourite
        
        let noOfProxies = offer.proxies.count
        let proxyTypeString = offer.proxies.first?.proxyType ?? "N/A"
        let ipTypeString = offer.proxies.first?.ipType ?? "N/A"
        let countryString = offer.proxies.first?.countryName ?? ""
        let sla = slaToDisplay(proxies: offer.proxies)
        
        trafficLabel.text = offer.trafficMB + " MB"
        durationLabel.text = offer.durationMin.daysHoursMinutesFormated()
        priceIPSXLabel.text = offer.priceIPSX
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
        
        let newCosntraintValue: CGFloat = editMode ? 59 : 15
        if let leadingConstraint = cellLeadingConstraint, newCosntraintValue != leadingConstraint.constant {
            leadingConstraint.constant = newCosntraintValue
            UIView.animate(withDuration: 0.15) { self.layoutIfNeeded() }
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
