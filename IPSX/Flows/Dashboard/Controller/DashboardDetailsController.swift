//
//  DashboardDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 03/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardDetailsController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var progressView: ProgressRoundView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var offerTypeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var trafficLabel: UILabel!
    @IBOutlet weak var trafficRemainedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationRemainedLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
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
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    private let cellSpacing: CGFloat = 12
    
    fileprivate let reuseIdentifier = "DashboardtemCell"
    var offer: Offer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
        let sla = slaToDisplay(proxies: offer.proxies)
        
        trafficLabel.text = offer.trafficMB + " MB"
        durationLabel.text = offer.durationMin.daysHoursMinutesFormated()
        progressView.progress = Double(sla)
        progressLabel.text = "\(sla)%"
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

extension DashboardDetailsController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}
