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
    @IBOutlet weak var favoritesImageView: UIImageView!
    @IBOutlet weak var fetchPageFooterView: UIView!
    @IBOutlet weak var fetchpageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var cartView: UIView!
    
    var isLoggedIn = UserManager.shared.isLoggedIn
    private var normalisedFiltersDictionary: [String:Any] = [:]
    private var filtersDictionary: [String:Any] = [:] {
        didSet {
            filtersCounterLabel.textColor = filtersDictionary.values.count > 0 ? UIColor.darkBlue : .warmGrey
            filtersTitleLabel.text =  filtersDictionary.values.count == 1 ? "Filter".localized : "Filters".localized
            let tailString = "active".localized
            filtersCounterLabel.text = "\(filtersDictionary.values.count) \(tailString)"
        }
    }
    var allOffers: [Offer] = []
    var offersDataSource: [Offer] = [] {
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
    var selectedOffer: Offer?
    var favoritesSelected = false
    private var tutorialPresented = false
    private var shouldRefreshIp = true
    private var shouldRefreshData = true
    private var isLastCell = false
    private var cartItemsCount = 0
    private var favoritesItemsCount = 0
    private var offersLoadedOnLastRequest = 0
    
    @IBAction func favButtonAction(_ sender: UIButton) {
        
        favoritesSelected = !favoritesSelected
        if favoritesSelected {
            favoritesImageView.image = UIImage(named: "savedFav")
        }
        else {
            favoritesImageView.image = UIImage(named: "favorites")
        }
        normalisedFiltersDictionary["favorites"] = favoritesSelected
        loadOffers() {
            if self.offersDataSource.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureUI()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.tabBarController?.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
    }
    
    func configureUI() {
       
        customTabBar.isHidden = !isLoggedIn
        closeButton.isHidden = isLoggedIn
        customTabBar.selectIndex(1)
        customTabBar.onTap = { index in
            self.tabBarController?.selectedIndex = index
        }
        updateCountryOverlay(visible: false)
        
        if !isLoggedIn {
            
            favoritesView.alpha = 0.3
            cartView.alpha = 0.3
            favoritesView.isUserInteractionEnabled = false
            cartView.isUserInteractionEnabled = false
        }
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
        fetchpageActivityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.marketTutorialChecked(), !tutorialPresented {
            DispatchQueue.main.async { self.performSegue(withIdentifier: "MarketTutorialSegueID", sender: self) }
            tutorialPresented = true
        }
        else if shouldRefreshData {
            offersDataSource = []
            self.loadOffers {
                if self.offersDataSource.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }
        shouldRefreshData = false
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
        DispatchQueue.main.async { self.performSegue(withIdentifier: self.countrySelectionID, sender: nil) }
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

    @objc func loadOffers(completion:(()->Void)? = nil) {
        
        let offset = allOffers.count
        
        loadingView?.startAnimating()
        MarketplaceService().retrieveOffers(offset: offset, filters: normalisedFiltersDictionary, completionHandler: { result in
            
            DispatchQueue.main.async {
                self.loadingView?.stopAnimating()
                self.fetchpageActivityIndicator.stopAnimating()
            }
            
            switch result {
            case .success(let offersData):
                
                let data = offersData as? (offers: [Offer], fav: Int, cart: Int)
                self.offersLoadedOnLastRequest = (data?.offers ?? []).count
                self.allOffers.append(contentsOf: data?.offers ?? [])
                
                if self.normalisedFiltersDictionary["show_unavailable_offers"] as? Bool == true {
                    self.offersDataSource.append(contentsOf: data?.offers ?? [])
                }
                else {
                    let availableOffers = (data?.offers ?? []).filter { return $0.isAvailable == true }
                    self.offersDataSource.append(contentsOf: availableOffers)
                }
            
                self.cartItemsCount = data?.cart ?? 0
                self.favoritesItemsCount = data?.fav ?? 0
                
                print("CVI - offers loaded: ",self.offersLoadedOnLastRequest, "offset ",offset)
                
                DispatchQueue.main.async {
                    self.updateHeaderCounters()
                    completion?()
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getOffers, completion: {
                    self.loadOffers(completion: completion)
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
        
        shouldRefreshData = false
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
                srcController.countries = UserManager.shared.getCountryList()
                
                srcController.onCountrySelected = { selectedCountry in
                    self.countryRComponent.contentTextField?.text = selectedCountry
                    self.submitCountryButton.isEnabled = true
                }
            }
        case filtersSegueID:
            
            shouldRefreshData = true
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
        return offersDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MarketCell
        if offersDataSource.count > indexPath.row {
            cell.configure(offer: offersDataSource[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == (offersDataSource.count - 1) && tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
            isLastCell = true
        }
    }
}

extension MarketController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard !isLoggedIn || (userInfo?.countryID != "" && userInfo?.countryID != nil) else {
            updateCountryOverlay(visible: true)
            return
        }
        if offersDataSource.count > indexPath.row {
            selectedOffer = offersDataSource[indexPath.row]
        }
        
        if selectedOffer?.isAvailable == true {
            DispatchQueue.main.async { self.performSegue(withIdentifier: self.marketItemID, sender: self) }
        }
    }
}

extension MarketController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if isLastCell && offersLoadedOnLastRequest == offersLimitPerRequest {
            
            self.fetchpageActivityIndicator.startAnimating()
            
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0, execute: {
                self.loadOffers()
            })
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

