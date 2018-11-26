//
//  MarketItemController.swift
//  IPSX
//
//  Created by Calin Chitu on 19/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class MarketItemController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var progressView: ProgressRoundView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cartOverlayView: UIView!
    @IBOutlet weak var cartOverlayYConstraint: NSLayoutConstraint!
    @IBOutlet weak var offerTypeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var trafficLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var noOfProxiesLabel: UILabel!
    @IBOutlet weak var priceIPSXLabel: UILabel!
    
    private let cellSpacing: CGFloat = 12
    private let cartSegueID = "ViewCartSegueID"
    
    fileprivate let reuseIdentifier = "MarketItemCell"
    var offer: Offer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        
        guard let offer = offer else { return }
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
        cartOverlayView.alpha = 0
        updateCountryOverlay(visible: false)
    }
    
    private func slaToDisplay(proxies: [Proxy]) -> UInt32 {
        
        var slaTotal: UInt32 = 0
        for proxy in proxies {
            let intValue = UInt32(proxy.sla) ?? 0
            slaTotal += intValue
        }
        return slaTotal / UInt32(proxies.count)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        updateCountryOverlay(visible: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func viewCart(_ sender: Any) {
        performSegue(withIdentifier: cartSegueID, sender: self)
    }
    
    private func updateCountryOverlay(visible: Bool) {
        view.layoutIfNeeded()
        //self.tabBarController?.setTabBarVisible(visible: !visible, animated: true)
        self.cartOverlayYConstraint.constant = visible ? 0 : 500
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
            self.cartOverlayView.alpha = visible ? 1 : 0
        })
    }

}

extension MarketItemController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offer?.proxies.count ?? 0
    }
}

class CenteringFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView,
            let layoutAttributesArray = layoutAttributesForElements(in: collectionView.bounds),
            var candidate = layoutAttributesArray.first else { return proposedContentOffset }
        
        layoutAttributesArray.filter({$0.representedElementCategory == .cell }).forEach { layoutAttributes in
            
            if (velocity.x > 0 && layoutAttributes.center.x > candidate.center.x) ||
                (velocity.x <= 0 && layoutAttributes.center.x < candidate.center.x) {
                candidate = layoutAttributes
            }
        }
        
        return CGPoint(x: candidate.center.x - collectionView.bounds.width / 2, y: proposedContentOffset.y)
    }
    
}

//extension MarketItemController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//
//        return cellSpacing
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let frameSize = collectionView.frame.size
//        return CGSize(width: frameSize.width - cellSpacing, height: frameSize.height)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        return UIEdgeInsets(top: 0, left: cellSpacing / 2, bottom: 0, right: cellSpacing / 2)
//    }
//}
