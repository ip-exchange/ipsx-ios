//
//  DashboardViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import CVINetworkingFramework

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var fullMaskView: UIView!
    @IBOutlet weak var tokensAmountLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var proxiesSegmentController: UISegmentedControl!
    @IBOutlet weak var slidableView: UIView!
    @IBOutlet weak var providerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var providerView: ProviderView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var countries: [String] = []
    private var timer: Timer?
    let cellID = "ActivationDetailsCellID"
    var selectedProxy: Proxy? = nil
    var tokenRequests: [TokenRequest]?
    let dispatchGroup = DispatchGroup()
    
    var preventPurchase: Bool { return !UserManager.shared.companyVerified && UserManager.shared.userInfo?.hasOptedForLegal == true }

    var balance: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.tokensAmountLabel.text = self.balance
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
    var proxies: [Proxy] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    var filteredProxies: [Proxy] {
        get {
            let filterString = "active"
            let filtered = proxies.filter {
                if proxiesSegmentController.selectedSegmentIndex == 0 {
                    return $0.proxyDetails?.status == filterString
                } else {
                    return $0.proxyDetails?.status != filterString

                }
            }
            let sorted = filtered.sorted { $0.proxyDetails?.startDate ?? Date() > $1.proxyDetails?.startDate ?? Date() }
            return sorted
        }
    }
    
    @IBAction func unwindToDashboard(segue:UIStoryboardSegue) { }
    
    @IBAction func tokenRequestAction(_ sender: UIButton) {
        
        guard !preventPurchase else {
            self.toast?.showToastAlert("Company Not Validated Message".localized, type: .validatePending, dismissable: false)
            return
        }
        
        self.tokenRequests = UserManager.shared.tokenRequests
        self.performSegue(withIdentifier: "showTokenRequestSegueID", sender: nil)
    }
    
    @IBAction func tokenDepositAction(_ sender: Any) {
        
        guard !preventPurchase else {
            self.toast?.showToastAlert("Company Not Validated Message".localized, type: .validatePending, dismissable: false)
            return
        }
        
        self.tokenRequests = UserManager.shared.tokenRequests
        self.performSegue(withIdentifier: "tokenDepositSegueID", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.layer.cornerRadius = 5
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        providerView.providerDelegate = self
     }
    
    @objc func appWillEnterForeground() {
        updateReachabilityInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        tableView?.setContentOffset(.zero, animated: false)
        
        /*  No need to submit requests:
            - When no eth address: Close the app from Add Eth Address screen after Login (the user remains loggedIn)
            - When the user is not yet logged in: Login will be displayed from Tab Bar Controller (this is the first VC)
         */
        if UserManager.shared.isLoggedIn {
            
            if UserManager.shared.company == nil {
                companyDetails()
            }
            if UserManager.shared.providerSubmissionStatus == nil {
                providerDetails()
            }
            if UserManager.shared.hasEthAddress {
                
                if UserManager.shared.testProxyPack == nil {
                    retrieveTestProxyPackage()
                }
                if UserManager.shared.proxyPacks == nil {
                    retrieveProxyPackages()
                }
                if UserManager.shared.generalSettings == nil {
                    generalSettings()
                }
                // After Logout we should load the proxy countries if needed for Test Proxy
                if UserManager.shared.proxyCountries == nil && UserManager.shared.hasTestProxyAvailable {
                    getProxyCountryList()
                }
            }
           
            dispatchGroup.notify(queue: .main) {
                self.updateData()
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        self.timer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: slidableView, text: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        selectedProxy = nil
        updateProxyDataSource()
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else if self.toast?.currentText == "No internet connection".localized {
                self.toast?.hideToastAlert()
            }
        }
    }

    func hideMaskView() {
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.5, options: [], animations: {
            let shrink = CGAffineTransform(scaleX: 0.1, y: 0.1);
            let translate = CGAffineTransform(translationX: 0, y: 512)
            self.fullMaskView.transform = shrink.concatenating(translate)
        }, completion: { completed in
            self.fullMaskView.isHidden = true
            self.tabBarController?.setTabBarVisible(visible: true, animated: true)
        })
    }
    
    func configureProviderView() {
        
        if UserManager.shared.userInfo?.hasOptedForProvider == false {
            hideProviderView()
        }
        else {
            providerViewHeight.constant = 66
            let providerStatus = UserManager.shared.providerSubmissionStatus
            providerView.subbmissionStatus = providerStatus
        }
    }
    
    func hideProviderView() {
        
        DispatchQueue.main.async {
            self.providerView.clipsToBounds = true
            self.providerViewHeight.constant = 0
        }
    }
    
    func updateReachabilityInfo() {
        DispatchQueue.main.async {
            if !ReachabilityManager.shared.isReachable() {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else if self.toast?.currentText == "No internet connection".localized {
                self.toast?.hideToastAlert()
            }
        }
    }

    @objc func updateData() {
        retrieveUserInfo()
        providerDetails()
        retrieveProxiesForCurrentUser()
    }
    
    func retrieveTestProxyPackage() {
        
        dispatchGroup.enter()
        loadingView?.startAnimating()
        ProxyService().retrieveProxyPackages(testPackage: true, completionHandler: { result in
            
            self.dispatchGroup.leave()
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let packages):
                UserManager.shared.testProxyPack = (packages as? [ProxyPack])?.first
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.retrieveTestProxyPackage, completion: {
                    self.retrieveTestProxyPackage()
                })
            }
        })
    }
    
    func retrieveProxyPackages() {
        
        dispatchGroup.enter()
        loadingView?.startAnimating()
        ProxyService().retrieveProxyPackages(completionHandler: { result in
            
            self.dispatchGroup.leave()
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let packages):
                UserManager.shared.proxyPacks = packages as? [ProxyPack]
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.retrieveProxyPackages, completion: {
                    self.retrieveProxyPackages()
                })
            }
        })
    }
    
    func generalSettings() {
        
        dispatchGroup.enter()
        SettingsService().retrieveSettings(completionHandler: { result in
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let settings):
                UserManager.shared.generalSettings = settings as? GeneralSettings
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.generalSettings, completion: {
                    self.generalSettings()
                })
            }
        })
    }
    
    func companyDetails() {
        
        dispatchGroup.enter()
        LegalPersonService().getCompanyDetails(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let company):
                UserManager.shared.company = company as? Company
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getCompany, completion: {
                    self.companyDetails()
                })
            }
        })
    }
    
    func providerDetails() {
        
        dispatchGroup.enter()
        ProviderService().getProviderStatus(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let status):
                UserManager.shared.providerSubmissionStatus = status as? ProviderStatus
                DispatchQueue.main.async {
                    self.configureProviderView()
                }
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getProviderDetails, completion: {
                    self.providerDetails()
                })
            }
        })
    }
    
    private func showZeroBalanceToastIfNeeded() {
        
        guard !preventPurchase else {
            return
        }

        let balanceValue = UserManager.shared.userInfo?.balance ?? 0
        balance = UserManager.shared.userInfo?.balance?.cleanString ?? "0"
        if balanceValue == 0, UserManager.shared.isLoggedIn {
            toast?.showToastAlert("Balance Empty Info Message".localized, type: .info)
        } else {
            toast?.hideToast()
        }
    }
    
    func retrieveUserInfo() {
        
        loadingView?.startAnimating()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                self.balance = UserManager.shared.userInfo?.balance?.cleanString ?? "0"
                self.showZeroBalanceToastIfNeeded()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.retrieveUserInfo()
                })
            }
        })
    }
    
    func retrieveProxiesForCurrentUser() {
        
        loadingView?.startAnimating()
        ProxyService().retrieveProxiesForCurrentUser(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let proxyArray):
                UserManager.shared.proxies = proxyArray as? [Proxy]
                self.updateProxyDataSource()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.retrieveProxies, completion: {
                    self.retrieveProxiesForCurrentUser()
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "FreeProxySegueID":
            let navController = segue.destination as? UINavigationController
            let destinationVC = navController?.viewControllers.first as? SearchViewController
            destinationVC?.isProxyFlow = true
            destinationVC?.countries = countries
            destinationVC?.proxy = selectedProxy
            
        case "ProxyDetailsSegueiID":
            let nextVC = segue.destination as? ProxyDetailsViewController
            nextVC?.proxy = selectedProxy
            nextVC?.presentedFromDashboard = true
            
        case "showTokenRequestSegueID":
            let nextVC = segue.destination as? UINavigationController
            let controller = nextVC?.viewControllers.first as? TokenRequestListController
            controller?.tokenRequests = tokenRequests ?? []
            
        default:
            break
        }
    }
    
    @IBAction func proxySegmentAction(_ sender: UISegmentedControl) {
        tableView?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView?.setContentOffset(.zero, animated: true)
        }
    }
    
    func updateProxyDataSource() {
        
        proxies = UserManager.shared.proxies ?? []
        if UserManager.shared.hasTestProxyAvailable && UserManager.shared.testProxyPack != nil {
            
            let testProxyPack = UserManager.shared.testProxyPack
            
            //TODO (CVI): simplify this formatting for duration -> move to extension
            
            let duration = testProxyPack?.duration ?? "0"
            var formatedDuration = duration + " min"
            if let intDuration = Int(duration) {
                let components = DateFormatter.secondsToDaysHoursMinutes(seconds: Int(intDuration * 60))
                formatedDuration = DateFormatter.readableDaysHoursMinutes(components:components)
            }
            
            let testProxyActivationDetails = ProxyActivationDetails(usedMB: "0", remainingDuration: formatedDuration, status: "active")
            let testProxy = Proxy(proxyPack: testProxyPack, proxyDetails: testProxyActivationDetails, isTestProxy: true)
            proxies.insert(testProxy, at: 0)
        }
    }
    
    func getProxyCountryList() {
        
        dispatchGroup.enter()
        loadingView?.startAnimating()
        ProxyService().getProxyCountryList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let countryList):
                UserManager.shared.proxyCountries = countryList as? [String]
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getProxyCountryList, completion: {
                    self.getProxyCountryList()
                })
            }
        })
    }
}

extension DashboardViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension DashboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProxies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProxyActivationDetailsCell
        cell.cellContentView.shadow = true
        cell.configure(proxy: filteredProxies[indexPath.item])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 5))
        footerView.backgroundColor = .clear
        return footerView
    }

}

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedProxy = filteredProxies[indexPath.item]
        
        if selectedProxy?.isTestProxy == true {
            
            let calendar = Calendar.current
            let minDurationString = selectedProxy?.proxyPack?.duration ?? "0"
            selectedProxy?.proxyDetails?.startDate = Date()
            selectedProxy?.proxyDetails?.endDate = calendar.date(byAdding: .minute, value: Int(minDurationString) ?? 0, to: Date())
            
            countries = UserManager.shared.proxyCountries ?? []
            self.performSegue(withIdentifier: "FreeProxySegueID", sender: self)
        }
        else {
            performSegue(withIdentifier: "ProxyDetailsSegueiID", sender: self)
        }
    }
}

extension DashboardViewController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Refresh Data Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            if requestType == RequestType.getProviderDetails {
                self.hideProviderView()
            }
            else {
                self.errorMessage = "Refresh Data Error Message".localized
            }
        }
    }
}

extension DashboardViewController: ProviderDelegate {
    
    func openProviderDetails(hasSubmittedProviderRequest: Bool) {
        
        if hasSubmittedProviderRequest {
            performSegue(withIdentifier: "showAboutProviderSegue", sender: nil)
        }
        else {
            performSegue(withIdentifier: "showBecomeProviderSegue", sender: nil)
        }
    }
}
