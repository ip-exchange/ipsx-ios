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
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    let cellID = "ProxyPackCellID"
    let countrySelectionID = "CountrySearchSegueID"
    var countries: [String]?
    var proxyPacks : [ProxyPack]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var selectedPack: ProxyPack?
    var balance: String = "" {
        didSet {
            DispatchQueue.main.async {
            }
        }
    }
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    var shouldRefreshIp = true
    
    private var tutorialPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
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
        balance = userInfo?.balance?.cleanString ?? "0"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        retrieveUserInfo()
        updateReachabilityInfo()
        
        // After Logout
        if UserManager.shared.proxyCountries == nil {
            getProxyCountryList()
        }
        if UserManager.shared.proxyPacks == nil {
            retrieveProxyPackages()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        countries  = UserManager.shared.proxyCountries
        proxyPacks = UserManager.shared.proxyPacks
        
        if !UserDefaults.standard.marketTutorialChecked(), !tutorialPresented {
            performSegue(withIdentifier: "MarketTutorialSegueID", sender: self)
            tutorialPresented = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
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
    
    func getProxyCountryList() {
        
        loadingView?.startAnimating()
        ProxyService().getProxyCountryList(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let countryList):
                UserManager.shared.proxyCountries = countryList as? [String]
                self.countries = UserManager.shared.proxyCountries
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getProxyCountryList, completion: {
                    self.getProxyCountryList()
                })
            }
        })
    }
    
    func retrieveProxyPackages() {
        
        loadingView?.startAnimating()
        ProxyService().retrieveProxyPackages(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let packages):
                UserManager.shared.proxyPacks = packages as? [ProxyPack]
                self.proxyPacks = UserManager.shared.proxyPacks
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.retrieveProxyPackages, completion: {
                    self.retrieveProxyPackages()
                })
            }
        })
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
    
    func retrieveUserInfo() {
        
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            switch result {
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                self.balance = UserManager.shared.userInfo?.balance?.cleanString ?? "0"
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.retrieveUserInfo()
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == countrySelectionID {
            let navController = segue.destination as? UINavigationController
            let destinationVC = navController?.viewControllers.first as? SearchViewController
            destinationVC?.onCountrySelected = { selectedCountry in
            }
            destinationVC?.isProxyFlow = true
            destinationVC?.countries = countries
            destinationVC?.proxyPack = selectedPack
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let _ = viewController as? MarketController {
            tutorialPresented = false
        }
    }
}

extension MarketController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MarketCell
        cell.cellContentView.shadow = true
        let progress = Double(arc4random_uniform(100))
        cell.progressView.progress = progress
        cell.progressLabel.text = "\(Int(progress))%"
        return cell
    }
}

extension MarketController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toast?.showToastAlert("Miauuuuuuu")
        
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
