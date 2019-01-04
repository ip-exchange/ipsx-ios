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
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var openSettingsOverlayView: UIView!
    @IBOutlet weak var openSettingsCenterConstraint: NSLayoutConstraint!

    @IBOutlet weak var activeStateView: CellStateRoundedView!
    @IBOutlet weak var doubleProgressView: DoubleProgressView!
    
    @IBOutlet weak var lockedOnIp1Label: UILabel!
    @IBOutlet weak var lockedOnIp2Label: UILabel!
    @IBOutlet weak var lockedOnIp3Label: UILabel!
    
    @IBOutlet weak var refundButton: RoundedButton!
    @IBOutlet weak var refundButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var refundInfoHolderView: RoundedView!
    @IBOutlet weak var refundInfoTopConstraint: NSLayoutConstraint!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    private let cellSpacing: CGFloat = 12
    private var currentProxy: Proxy?
    
    fileprivate let reuseIdentifier = "DashboardtemCell"
    private var viewRefundSegue = "ViewRefundDetailsSegue"
    
    var offer: Offer?
    var shouldDismiss = false
    
    private var firstProxyLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.doubleProgressView.setProgress(upProgress: 0, downProgress: 0, animated: false)
        updateHeaderWithProxy(nil, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: noOfProxiesLabel, text: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let firstProxy = offer?.proxies.first, !firstProxyLoaded {
            updateHeaderWithProxy(firstProxy, animated: true)
        }
        firstProxyLoaded = true
    }
    
    func configureUI() {
        
        backButton.isHidden = shouldDismiss
        dismissButton.isHidden = !shouldDismiss
        
        self.openSettingsOverlayView.alpha = 0
        self.openSettingsCenterConstraint.constant = 500
        
        let noOfProxies = offer?.proxies.count ?? 0
        let proxyTypeString = offer?.proxies.first?.proxyType ?? "N/A"
        let ipTypeString = offer?.proxies.first?.ipType ?? "N/A"
        
        trafficLabel.text = offer?.trafficMB ?? "0" + " MB"
        durationLabel.text = offer?.durationMin.daysHoursMinutesFormated()
        flagImageView.image = UIImage(named: "worldPins")
        
        countryLabel.text = offer?.calculateCountryToDisplay()
        
        if noOfProxies > 1 {
            noOfProxiesLabel.text = "\(noOfProxies)" + " proxy items"
            offerTypeLabel.text = "Grouped offer".localized
        }
        else {
            noOfProxiesLabel.text = "\(noOfProxies)" + " proxy item"
            offerTypeLabel.text = "\(noOfProxies)" + "IP-" + proxyTypeString + "-" + ipTypeString
            
            if let flagString = offer?.proxies.first?.flagUrlName,
                let flagUrl = URL(string: flagString),
                let flagImage = UIImage(named: flagUrl.deletingPathExtension().lastPathComponent) {
                flagImageView.image = flagImage
            }
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeOverlayAction(_ sender: Any) {
        hideOverlay()
    }

    @IBAction func refundAction(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowrefundSegueID", sender: self)
    }
    
    @IBAction func refundInfoViewAction(_ sender: Any) {
        self.performSegue(withIdentifier: self.viewRefundSegue, sender: self)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowrefundSegueID" {
            let dest = segue.destination as? RefundRequestController
            dest?.proxy = currentProxy
            dest?.onRefundSuccess = {
                self.currentProxy?.hasRequestedRefund = true
                self.refundButtonTopConstraint.constant = -100
                self.refundInfoTopConstraint.constant = 16
                self.view.layoutIfNeeded()
            }
        }
        if segue.identifier == viewRefundSegue {
            let dest = segue.destination as? RefundDetailsController
            //TODO (CVI): Pass data here
        }
    }
    
    fileprivate func updateHeaderWithProxy(_ proxy: Proxy?, animated: Bool = true) {
        
        currentProxy = proxy
        refundInfoTopConstraint.constant = -100
        refundButtonTopConstraint.constant = -100
        
        if animated { UIView.animate(withDuration: 0.15) { self.view.layoutIfNeeded() } }
        
        if animated {
            self.lockedOnIp1Label.labelTransition(0.15)
            self.lockedOnIp2Label.labelTransition(0.15)
            self.lockedOnIp3Label.labelTransition(0.15)
            self.trafficLabel.labelTransition(0.15)
            self.trafficRemainedLabel.labelTransition(0.15)
            self.durationLabel.labelTransition(0.15)
            self.durationRemainedLabel.labelTransition(0.15)
        }
        
        guard let validProxy = proxy, let offer = offer else {
            self.lockedOnIp1Label.text = "---.---.---.---"
            self.lockedOnIp2Label.text = ""
            self.lockedOnIp3Label.text = ""
            self.trafficLabel.text = "--- MB"
            self.trafficRemainedLabel.text = "--- MB"
            self.durationLabel.text = "--- min"
            self.durationRemainedLabel.text = "--- min"
            
            UIView.animate(withDuration: 0.15) {
                self.activeStateView.alpha = 0
            }
            return
        }
        
        let usageMb = Double(validProxy.usage ?? "0") ?? 0
        let progressMb = Double(offer.trafficMB) ?? 0
        var usageProgress = progressMb > 0 ? usageMb / progressMb : 0
        if usageProgress < 0 { usageProgress = 0 }

        let remainedMin = Double(validProxy.remainingMinutes()) ?? 0
        let durationMin = Double(offer.durationMin) ?? 0
        var durationProgress = durationMin > 0 ? (durationMin - remainedMin) / durationMin : 1
        if durationProgress < 0 { durationProgress = 1 }
        if durationProgress > 1 { durationProgress = 1 }

        self.trafficLabel.text = offer.trafficMB + " MB"
        self.durationLabel.text = offer.durationMin.daysHoursMinutesFormated()
        
        if let endDate = validProxy.endDate {
            let refundRequested: Bool = proxy?.hasRequestedRefund ?? false
            if refundRequested {
                refundInfoTopConstraint.constant = 16
            }
            let daysToRefund: Int = Int(UserManager.shared.generalSettings?.proxyDaysRefund ?? "0") ?? 0
            let diffInDays = Calendar.current.dateComponents([.day], from: endDate, to: Date()).day ?? 0
            if !refundRequested && diffInDays <= daysToRefund {
                refundButtonTopConstraint.constant = 24
                refundButton.isEnabled = true
            }
            if animated { UIView.animate(withDuration: 0.15) { self.view.layoutIfNeeded() } }
        }
        
        var pos = 0
        for lockedIp in validProxy.lockedOnIPs ?? ["---.---.---.---"] {
            if pos == 0 { self.lockedOnIp1Label.text = lockedIp }
            if pos == 1 { self.lockedOnIp1Label.text = lockedIp }
            if pos == 2 { self.lockedOnIp1Label.text = lockedIp }
            pos += 1
        }
        
        activeStateView.setActiveState(validProxy.status)

        if validProxy.status == "unavailable" {
            self.trafficRemainedLabel.text = "--- MB"
            self.durationRemainedLabel.text = "--- min"
            durationProgress = 0
            usageProgress = 0
        } else {
            self.trafficRemainedLabel.text = "\(Int(usageMb))" + " MB"
            let duration = remainedMin >  0 ? Int(durationMin - remainedMin) : Int(durationMin)
            self.durationRemainedLabel.text = "~ " + "\(duration)".daysHoursMinutesFormated()
        }
        
        self.doubleProgressView.setProgress(upProgress: Float(usageProgress), downProgress: Float(durationProgress), animated: animated)
        
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
