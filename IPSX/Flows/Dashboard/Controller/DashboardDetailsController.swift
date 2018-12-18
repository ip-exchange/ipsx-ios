//
//  DashboardDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 03/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardDetailsController: UIViewController {

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var offerTypeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var trafficLabel: UILabel!
    @IBOutlet weak var trafficRemainedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationRemainedLabel: UILabel!
    @IBOutlet weak var noOfProxiesLabel: UILabel!
    @IBOutlet weak var noOfproxiesTopConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint = noOfproxiesTopConstraint
        }
    }
    
    @IBOutlet weak var openSettingsOverlayView: UIView!
    @IBOutlet weak var openSettingsCenterConstraint: NSLayoutConstraint!

    @IBOutlet weak var activeStateView: CellStateRoundedView!
    @IBOutlet weak var doubleProgressView: DoubleProgressView!
    
    @IBOutlet weak var lockedOnIp1Label: UILabel!
    @IBOutlet weak var lockedOnIp2Label: UILabel!
    @IBOutlet weak var lockedOnIp3Label: UILabel!
    
    @IBOutlet weak var refundButton: RoundedButton!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    private let cellSpacing: CGFloat = 12
    
    fileprivate let reuseIdentifier = "DashboardtemCell"
    var offer: Offer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        if let firstProxy = offer?.proxies.first {
            updateHeaderWithProxy(firstProxy)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: noOfProxiesLabel, text: "")
    }

    func configureUI() {
        
        guard let offer = offer else { return }
        
        self.openSettingsOverlayView.alpha = 0
        self.openSettingsCenterConstraint.constant = 500

        let noOfProxies = offer.proxies.count
        let proxyTypeString = offer.proxies.first?.proxyType ?? "N/A"
        let ipTypeString = offer.proxies.first?.ipType ?? "N/A"
        let countryString = offer.proxies.first?.countryName ?? ""
        
        trafficLabel.text = offer.trafficMB + " MB"
        durationLabel.text = offer.durationMin.daysHoursMinutesFormated()
        flagImageView.image = UIImage(named: "worldPins")
        
        if noOfProxies > 1 {
            noOfProxiesLabel.text = "\(noOfProxies)" + " proxy items"
            offerTypeLabel.text = "Grouped offer".localized
            countryLabel.text = ""
        }
        else {
            noOfProxiesLabel.text = "\(noOfProxies)" + " proxy item"
            offerTypeLabel.text = "\(noOfProxies)" + "IP-" + proxyTypeString + "-" + ipTypeString
            countryLabel.text = countryString
            
            if let flagString = offer.proxies.first?.flagUrlName,
                let flagUrl = URL(string: flagString),
                let flagImage = UIImage(named: flagUrl.deletingPathExtension().lastPathComponent) {
                flagImageView.image = flagImage
            }
        }
    }
    
    private func slaToDisplay(proxies: [Proxy]) -> Int {
        
        var slaTotal: Int = 0
        for proxy in proxies {
            slaTotal += proxy.sla
        }
        return slaTotal / proxies.count
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeOverlayAction(_ sender: Any) {
        hideOverlay()
    }

    @IBAction func refundAction(_ sender: Any) {
    }
    
    @IBAction func openSettingsAction(_ sender: Any) {
        
        guard let settingsUrl = URL(string: "App-Prefs:root=WIFI") else {
            hideOverlay()
            toast?.showToastAlert("Select Valid ETH Wallet Message".localized, type: .error)
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        } else {
            hideOverlay()
            toast?.showToastAlert("Redirect to Settings Error Message".localized, type: .error)
        }
    }

    private func hideOverlay() {
        view.layoutIfNeeded()
        self.openSettingsCenterConstraint.constant = 500
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
            self.openSettingsOverlayView.alpha = 0
        })
    }

    fileprivate func updateHeaderWithProxy(_ proxy: Proxy?) {
        
        guard let validProxy = proxy, let offer = offer else {
            self.doubleProgressView.setProgress(upProgress: 0, downProgress: 0)
            self.refundButton.isEnabled = false
            self.lockedOnIp1Label.labelTransition(0.15)
            self.lockedOnIp1Label.text = "---.---.---.---"
            self.lockedOnIp2Label.labelTransition(0.15)
            self.lockedOnIp2Label.text = "---.---.---.---"
            self.lockedOnIp3Label.labelTransition(0.15)
            self.lockedOnIp3Label.text = "---.---.---.---"
            
            self.trafficLabel.labelTransition(0.15)
            self.trafficLabel.text = "--- MB"
            
            self.trafficRemainedLabel.labelTransition(0.15)
            self.trafficRemainedLabel.text = "--- MB"
            
            self.durationLabel.labelTransition(0.15)
            self.durationLabel.text = "--- min"

            self.durationRemainedLabel.labelTransition(0.15)
            self.durationRemainedLabel.text = "--- min"
            
            UIView.animate(withDuration: 0.15) {
                self.activeStateView.alpha = 0
                self.flagImageView.alpha = 0
            }
            return
        }
        
        let usageMb = Double(validProxy.usage ?? "0") ?? 0
        let progressMb = Double(offer.trafficMB) ?? 0
        var usageProgress = progressMb > 0 ? usageMb / progressMb : 0
        
        let remainedMin = Double(validProxy.remainingMinutes()) ?? 0
        let durationMin = Double(offer.durationMin) ?? 0
        var durationProgress = durationMin > 0 ? (durationMin - remainedMin) / durationMin : 0
        
        self.trafficLabel.labelTransition(0.15)
        self.trafficLabel.text = offer.trafficMB + " MB"
        
        self.durationLabel.labelTransition(0.15)
        self.durationLabel.text = offer.durationMin.daysHoursMinutesFormated()

        self.refundButton.isEnabled = true
        self.lockedOnIp1Label.labelTransition(0.15)
        self.lockedOnIp2Label.labelTransition(0.15)
        self.lockedOnIp3Label.labelTransition(0.15)
        
        var pos = 0
        for lockedIp in validProxy.lockedOnIPs ?? ["---.---.---.---", "---.---.---.---", "---.---.---.---"] {
            if pos == 0 { self.lockedOnIp1Label.text = lockedIp }
            if pos == 1 { self.lockedOnIp1Label.text = lockedIp }
            if pos == 2 { self.lockedOnIp1Label.text = lockedIp }
            pos += 1
        }
        
        if let flagString = proxy?.flagUrlName,
            let flagUrl = URL(string: flagString),
            let flagImage = UIImage(named: flagUrl.deletingPathExtension().lastPathComponent) {
            flagImageView.image = flagImage
        }

        activeStateView.setActiveState(validProxy.status)

        if validProxy.status == "unavailable" {
            self.trafficRemainedLabel.labelTransition(0.15)
            self.trafficRemainedLabel.text = "--- MB"
            self.durationRemainedLabel.labelTransition(0.15)
            self.durationRemainedLabel.text = "--- min"
            durationProgress = 0
            usageProgress = 0
        } else {
            self.trafficRemainedLabel.labelTransition(0.15)
            self.trafficRemainedLabel.text = "\(Int(usageMb))" + " MB"
            self.durationRemainedLabel.labelTransition(0.15)
            self.durationRemainedLabel.text = "\(Int(durationMin - remainedMin))".daysHoursMinutesFormated()
        }
        
        self.doubleProgressView.setProgress(upProgress: Float(usageProgress), downProgress: Float(durationProgress))
        
        UIView.animate(withDuration: 0.15) {
            self.activeStateView.alpha = 1
            self.flagImageView.alpha = 1
        }

    }
    

}


extension DashboardDetailsController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProxyItemCollectionViewCell
        if offer?.proxies.count ?? 0 > indexPath.row, let proxy = offer?.proxies[indexPath.row] {
            cell.configure(proxy: proxy)
            cell.onCopy = { packname, packurl in
                UIPasteboard.general.string = packurl
                self.openSettingsCenterConstraint.constant = 0
                self.openSettingsOverlayView.alpha = 1
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
                    self.view.layoutIfNeeded()
                })

            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offer?.proxies.count ?? 0
    }
}

extension DashboardDetailsController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        updateHeaderWithProxy(nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let visiblePoint = CGPoint(x: self.collectionView.contentOffset.x + self.collectionView.frame.size.width / 2,
                                  y: self.collectionView.frame.size.height / 2)
        if let path = self.collectionView.indexPathForItem(at: visiblePoint),
             let proxy = self.offer?.proxies[path.item] {
           self.updateHeaderWithProxy(proxy)
        }
        
     }
}

extension DashboardDetailsController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}
