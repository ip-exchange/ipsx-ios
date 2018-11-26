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
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    let cellID = "MarketCellID"
    let countrySelectionID = "CountrySearchSegueID"
    let marketItemID = "MarketItemSegueID"
    private var timer: Timer?
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
    var selectedOffer: Offer?
    var shouldRefreshIp = true
    
    private var tutorialPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        
        self.updateData()
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.marketTutorialChecked(), !tutorialPresented {
            performSegue(withIdentifier: "MarketTutorialSegueID", sender: self)
            tutorialPresented = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        performSegue(withIdentifier: "CountrySearchSegueID", sender: nil)
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
        
        loadingView?.startAnimating()
        MarketplaceService().retrieveOffers(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let offers):
                ProxyManager.shared.allOffers = offers as? [Offer]
                self.offers = ProxyManager.shared.allOffers ?? []
                
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
    
    private func updateCountryOverlay(visible: Bool) {
        view.layoutIfNeeded()
        //self.tabBarController?.setTabBarVisible(visible: !visible, animated: true)
        self.submitCountryButton.isEnabled = self.countryRComponent.contentTextField?.text != ""
        self.countryViewYAxiscenter.constant = visible ? 0 : 500
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
            self.countryOverlayView.alpha = visible ? 1 : 0
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case marketItemID:
            let destinationVC = segue.destination as? MarketItemController
            destinationVC?.offer = selectedOffer
            
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
        default: break
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let _ = viewController as? MarketController {
            tutorialPresented = false
        }
    }
    
    @IBAction func unwindToMarket(segue:UIStoryboardSegue) { }

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
        
        guard UserManager.shared.getCountryName(countryID: userInfo?.countryID) != nil else {
            updateCountryOverlay(visible: true)
            return
        }
        if offers.count > indexPath.row {
            selectedOffer = offers[indexPath.row]
        }
        
        print("SLA selected: ",selectedOffer?.proxies.first?.sla)
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.marketItemID, sender: self)
        }

//        tableView.deselectRow(at: indexPath, animated: false)
//
//        if let proxyPack = proxyPacks?[indexPath.row] {
//            self.selectedPack = proxyPack
//        }
//
//        let balanceValue = UserManager.shared.userInfo?.balance ?? 0
//        let packagePrice = Double(self.selectedPack?.price ?? "0") ?? 0
//
//        if balanceValue >= packagePrice {
//
//            switch ReachabilityManager.shared.connectionType {
//            case .wifi:
//                self.performSegue(withIdentifier: self.countrySelectionID, sender: nil)
//            case .cellular:
//                self.errorMessage = "Connect to WiFi network message".localized
//            case .none:
//                self.errorMessage = "No internet connection".localized
//            }
//        }
//        else {
//            self.errorMessage = "Insufficient Balance Error Message".localized
//        }
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
