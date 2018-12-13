//
//  MarketController.swift
//  IPSX
//
//  Created by Calin Chitu on 15/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class MarketController: UIViewController, UITabBarControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var countryOverlayView: UIView!
    @IBOutlet weak var countryViewYAxiscenter: NSLayoutConstraint!
    @IBOutlet weak var countryRComponent: RichTextFieldView!
    @IBOutlet weak var submitCountryButton: UIButton!
    @IBOutlet weak var filtersImage: UIImageView!
    @IBOutlet weak var filtersTitleLabel: UILabel!
    @IBOutlet weak var filtersCounterLabel: UILabel!
    @IBOutlet weak var cartCountLabel: UILabel!
    @IBOutlet weak var favoritesCounterLabel: UILabel!
    @IBOutlet weak var customTabBar: CustomTabBar!

    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    private var normalisedFiltersDictionary: [String:Any] = [:]
    private var filtersDictionary: [String:Any] = [:] {
        didSet {
            filtersCounterLabel.textColor = filtersDictionary.values.count > 0 ? UIColor.darkBlue : .warmGrey
            filtersTitleLabel.text =  filtersDictionary.values.count == 1 ? "Filter".localized : "Filters".localized
            let tailString = "active".localized
            filtersCounterLabel.text = "\(filtersDictionary.values.count) \(tailString)"
        }
    }
    var offers: [Offer] = [] {
        didSet {
            DispatchQueue.main.async { self.tableView.reloadData() }
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
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    let cellID = "MarketCellID"
    let countrySelectionID = "CountrySearchSegueID"
    let marketItemID = "MarketItemSegueID"
    let filtersSegueID = "FiltersSegueID"
    private var timer: Timer?
    var selectedOffer: Offer?
    var shouldRefreshIp = true
    private var tutorialPresented = false
    private var backFromSegue = false

    private var cartItemsCount: Int = 0
    private var favoritesItemsCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customTabBar.selectIndex(1)
        customTabBar.onTap = { index in
            self.tabBarController?.selectedIndex = index
        }
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.tabBarController?.delegate = self
        updateCountryOverlay(visible: false)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func appWillEnterForeground() {
        updateReachabilityInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        
        if !backFromSegue { self.updateData() }
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if backFromSegue { self.updateData() }
        backFromSegue = false
        
        if !UserDefaults.standard.marketTutorialChecked(), !tutorialPresented {
            DispatchQueue.main.async { self.performSegue(withIdentifier: "MarketTutorialSegueID", sender: self) }
            tutorialPresented = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    @IBAction func closeCountryOverlay(_ sender: Any) {
        updateCountryOverlay(visible: false)
    }
    
    @IBAction func submitCountry(_ sender: Any) {
        
        if let selectedCountry = self.countryRComponent.contentTextField?.text, let countryID = UserManager.shared.getCountryId(countryName: selectedCountry) {
            let bodyParams: [String: Any] =  ["country_id": countryID as Any]
            
            loadingView?.startAnimating()
            UserInfoService().updateUserProfile(bodyParams: bodyParams, completionHandler: { result in
                
                self.loadingView?.stopAnimating()
                switch result {
                case .success(_):
                    self.retrieveUserInfo()
                    DispatchQueue.main.async {
                        self.countryRComponent.contentTextField?.text = ""
                        self.updateCountryOverlay(visible: false)
                    }
                case .failure(let error):
                    self.handleError(error, requestType: RequestType.updateProfile, completion: {
                        DispatchQueue.main.async {
                            self.countryRComponent.contentTextField?.text = ""
                            self.updateCountryOverlay(visible: false)
                        }
                    })
                }
            })
         }
    }
    
    @IBAction func selectCountry(_ sender: Any) {
        DispatchQueue.main.async { self.performSegue(withIdentifier: "CountrySearchSegueID", sender: nil) }
    }
    
    func updateReachabilityInfo() {
        
        if !ReachabilityManager.shared.isReachable() {
            self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
        } else if self.toast?.currentText == "No internet connection".localized {
            self.toast?.hideToastAlert()
        }
        
        guard shouldRefreshIp else { return }
        DispatchQueue.main.async {
            self.shouldRefreshIp = false
            switch ReachabilityManager.shared.connectionType {
            case .wifi, .cellular:
                IPService().getPublicIPAddress() { error, ipAddress in
                    DispatchQueue.main.async {
                        if ipAddress == nil {
                            self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
                        }
                    }
                }
            case .none:
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            }
        }
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            self.shouldRefreshIp = true
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else {
                self.toast?.hideToastAlert()
            }
            self.updateReachabilityInfo()
        }
    }
    
    @objc func updateData() {
        loadOffers()
    }
    
    func loadOffers() {
        
        //TODO (CVI): offset logic
        let offset = 0
        
        loadingView?.startAnimating()
        MarketplaceService().retrieveOffers(offset: offset, filters: normalisedFiltersDictionary, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let offersData):
                
                let data = offersData as? (offers: [Offer], fav: Int, cart: Int)
                if self.normalisedFiltersDictionary.values.count == 0  {
                    ProxyManager.shared.allOffers = data?.offers
                }
                self.offers = data?.offers ?? []
                self.cartItemsCount = data?.cart ?? 0
                self.favoritesItemsCount = data?.fav ?? 0
                
                DispatchQueue.main.async {
                    self.updateHeaderCounters()
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getOffers, completion: {
                    self.loadOffers()
                })
            }
        })
    }
    
    func retrieveUserInfo() {
        
        loadingView?.startAnimating()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.retrieveUserInfo()
                })
            }
        })
    }
    
    private func updateHeaderCounters() {
        
        cartCountLabel.textColor = cartItemsCount > 0 ? UIColor.darkBlue : .warmGrey
        let tailString = cartItemsCount == 1 ? "offer".localized : "offers".localized
        cartCountLabel.text = "\(cartItemsCount) \(tailString)"
        
        favoritesCounterLabel.textColor = favoritesItemsCount > 0 ? UIColor.darkBlue : .warmGrey
        let favTailString = "saved".localized
        favoritesCounterLabel.text = "\(favoritesItemsCount) \(favTailString)"
        
    }
    
    private func updateCountryOverlay(visible: Bool) {
        view.layoutIfNeeded()
        self.submitCountryButton.isEnabled = self.countryRComponent.contentTextField?.text != ""
        self.countryViewYAxiscenter.constant = visible ? 0 : 500
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
            self.countryOverlayView.alpha = visible ? 1 : 0
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        backFromSegue = true
        segue.destination.hidesBottomBarWhenPushed = true
        
        switch segue.identifier {
            
        case marketItemID:
            let destinationVC = segue.destination as? MarketItemController
            destinationVC?.offer = selectedOffer
            destinationVC?.isInCartAlready = selectedOffer?.isAddedToCart ?? false
            
        case countrySelectionID:
            
            let navController = segue.destination as? UINavigationController
            if let srcController = navController?.viewControllers.first as? SearchViewController {
                srcController.dismissPresentingNav = true
                srcController.countries = UserManager.shared.getUserCountryList()
                
                srcController.onCountrySelected = { selectedCountry in
                    self.countryRComponent.contentTextField?.text = selectedCountry
                    self.submitCountryButton.isEnabled = true
                }
            }
        case filtersSegueID:
            let navController = segue.destination as? UINavigationController
            let filterController = navController?.viewControllers.first as? MarketFilterController
            filterController?.filtersDictionary = self.filtersDictionary
            filterController?.onApplyFilters = { filtersDic, normalisedDic in
                print("Filters: --->\n\(normalisedDic)\nFilters: <---")
                self.filtersDictionary = filtersDic
                self.normalisedFiltersDictionary = normalisedDic
            }
        default: break
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let _ = viewController as? MarketController {
            tutorialPresented = false
        }
    }
    
    @IBAction func unwindToMarket(segue:UIStoryboardSegue) {}

}

extension MarketController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MarketCell
        if offers.count > indexPath.row {
            cell.configure(offer: offers[indexPath.row])
        }
        return cell
    }
}

extension MarketController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard userInfo?.countryID != nil else {
            updateCountryOverlay(visible: true)
            return
        }
        if offers.count > indexPath.row {
            selectedOffer = offers[indexPath.row]
        }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.marketItemID, sender: self)
        }
    }
}

extension MarketController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension MarketController: ErrorPresentable {
    
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

