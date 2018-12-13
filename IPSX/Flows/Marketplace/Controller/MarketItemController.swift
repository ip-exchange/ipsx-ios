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

    
    @IBOutlet weak var noWalletTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var noWalletView: RoundedView!
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
    @IBOutlet weak var favoritesButton: UIButton!
    
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
        noWalletTopConstraint.constant = -60
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noWalletTopConstraint.constant = -60
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserManager.shared.roles == nil {
            getUserRoles(completionHandler: { _ in })
        }
    }
    
    func configureUI() {
        
        guard let offer = offer else { return }
        let noOfProxies = offer.proxies.count
        let proxyTypeString = offer.proxies.first?.proxyType ?? "N/A"
        let ipTypeString = offer.proxies.first?.ipType ?? "N/A"
        let countryString = offer.proxies.first?.countryName ?? ""
        let sla = slaToDisplay(proxies: offer.proxies)
        
        favoritesButton.isSelected = offer.isFavourite
        addToCartButton.isEnabled = !isInCartAlready
        addToCartButton.setTitle("Added to Cart".localized, for: .disabled)
        trafficLabel.text = offer.trafficMB + " MB"
        durationLabel.text = offer.durationMin.daysHoursMinutesFormated()
        priceIPSXLabel.text = offer.priceIPSX
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
        
        noWalletView.isHidden = true
        if UserManager.shared.roles == nil {
            self.errorMessage = "Generic Error Message".localized
        } else if UserManager.shared.roles?.contains(.Requester) == false {
            noWalletView.isHidden = false
            noWalletTopConstraint.constant = 7
            UIView.animate(withDuration: 0.15) { self.view.layoutIfNeeded() }
        } else {
            self.performAddToCartRequest(offerIds: [offer.id])
        }
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func viewCart(_ sender: Any) {
        DispatchQueue.main.async { self.performSegue(withIdentifier: self.cartSegueID, sender: self) }
    }
    
    @IBAction func favoritesAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        //TODO: Favorites API here when ready
    }
    
    private func getUserRoles(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        self.loadingView.startAnimating()
        UserInfoService().getRoles(completionHandler: { result in
            self.loadingView.stopAnimating()
            switch result {
                
            case .failure(let error):
                completionHandler(ServiceResult.failure(error))
                
            case .success(let userRoles):
                UserManager.shared.roles = userRoles as? [UserRoles]
                completionHandler(ServiceResult.success(true))
            }
        })
    }

    private func updateCountryOverlay(visible: Bool) {
        view.layoutIfNeeded()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateWalletSegue" {
            let dest = segue.destination as? GenerateAddressController
            dest?.cartFlow = true
        }
    }
    
    @IBAction func unwindMarketItem(segue:UIStoryboardSegue) {}

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
