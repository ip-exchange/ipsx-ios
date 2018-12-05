//
//  MarketItemController.swift
//  IPSX
//
//  Created by Calin Chitu on 19/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

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
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var addToCartButton: RoundedButton!
    @IBOutlet weak var topSeparatorConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint = topSeparatorConstraint
        }
    }
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }

    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var isInCartAlready = false

    private let cellSpacing: CGFloat = 12
    private let cartSegueID = "ViewCartSegueID"
    
    fileprivate let reuseIdentifier = "MarketItemCell"
    var offer: Offer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    func configureUI() {
        
        guard let offer = offer else { return }
        let noOfProxies = offer.proxies.count
        let proxyTypeString = offer.proxies.first?.proxyType ?? "N/A"
        let ipTypeString = offer.proxies.first?.ipType ?? "N/A"
        let countryString = offer.proxies.first?.countryName ?? ""
        let sla = slaToDisplay(proxies: offer.proxies)
        
        addToCartButton.isEnabled = !isInCartAlready
        addToCartButton.setTitle("Added to Cart".localized, for: .disabled)
        trafficLabel.text = offer.trafficMB + " MB"
        durationLabel.text = offer.durationMin.daysHoursMinutesFormated()
        priceIPSXLabel.text = offer.priceIPSX
        progressView.progress = Double(sla)
        progressLabel.text = "\(sla)%"
        
        if noOfProxies > 1 {
            noOfProxiesLabel.text = "\(noOfProxies)" + " proxy items"
            flagImageView.image = UIImage(named: "worldPins")
            offerTypeLabel.text = "Grouped offer".localized
            countryLabel.text = ""
        }
        else {
            noOfProxiesLabel.text = "\(noOfProxies)" + " proxy item"
            flagImageView.image = UIImage(named: "RO32") //TODO
            offerTypeLabel.text = "\(noOfProxies)" + "IP-" + proxyTypeString + "-" + ipTypeString
            countryLabel.text = countryString
        }
        cartOverlayView.alpha = 0
        updateCountryOverlay(visible: false)
    }
    
    private func slaToDisplay(proxies: [Proxy]) -> Int {
        
        var slaTotal: Int = 0
        for proxy in proxies {
            slaTotal += proxy.sla
        }
        return slaTotal / proxies.count
    }
    
    @IBAction func addToCart(_ sender: Any) {
        
        guard let offer = offer else { return }
        self.performAddToCartRequest(offerIds: [offer.id])
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
    
    func performAddToCartRequest(offerIds: [Int]) {
        
        loadingView?.startAnimating()
        MarketplaceService().addToCart(offerIds: offerIds, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                DispatchQueue.main.async { self.updateCountryOverlay(visible: true) }
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.addToCart, completion: {
                    self.performAddToCartRequest(offerIds: offerIds)
                })
            }
        })
    }
}

extension MarketItemController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProxyItemCollectionViewCell
        if offer?.proxies.count ?? 0 > indexPath.row, let proxy = offer?.proxies[indexPath.row] {
            cell.configure(proxy: proxy)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offer?.proxies.count ?? 0
    }
}

extension MarketItemController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension MarketItemController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}

//TODO: This is reused in dashboard, move in it's own file
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
