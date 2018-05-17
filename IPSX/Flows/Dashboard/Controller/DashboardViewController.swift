//
//  DashboardViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var tokensAmountLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var proxiesSegmentController: UISegmentedControl!
    @IBOutlet weak var slidableView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var countries: [String] = []
        
    var balance: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.tokensAmountLabel.text = self.balance
            }
        }
    }
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
       }
    }
    let cellID = "ActivationDetailsCellID"
    var selectedProxy: Proxy? = nil
    var tokenRequests: [TokenRequest]?
    var proxies: [Proxy] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    var filteredProxies: [Proxy] {
        get {
            let filterString = proxiesSegmentController.selectedSegmentIndex == 0 ? "active".localized : "expired".localized
            return proxies.filter { $0.proxyDetails?.status == filterString }
         }
    }
    
    @IBAction func unwindToDashboard(segue:UIStoryboardSegue) { }
    
    @IBAction func tokenRequestAction(_ sender: UIButton) {
        
        self.tokenRequests = UserManager.shared.tokenRequests
        self.performSegue(withIdentifier: "showTokenRequestSegueID", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO (CVI): refresh data when needed (proxy usage -> x sec & balance after token requests / activate proxy)
     }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: slidableView, text: "Invalid Credentials")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        selectedProxy = nil
        updateProxyDataSource()
        self.balance = "\(UserManager.shared.userInfo?.balance ?? 0)"
        
        if UserManager.shared.isLoggedIn {
            initializeData()
        }
    }
    
    func initializeData() {
        
        if UserManager.shared.userInfo == nil {
            
            UserInfoService().retrieveUserInfo(completionHandler: { result in
                
                switch result {
                case .success(let user):
                    UserManager.shared.userInfo = user as? UserInfo
                    self.balance = "\(UserManager.shared.userInfo?.balance ?? 0)"
                    
                case .failure(_):
                    self.errorMessage = "Generic Error Message".localized
                }
            })
        }
        
        if UserManager.shared.proxies == nil {
            
            loadingView.startAnimating()
            ProxyService().retrieveProxiesForCurrentUser(completionHandler: { result in
                self.loadingView.stopAnimating()
                
                switch result {
                    
                case .success(let proxyArray):
                    UserManager.shared.proxies = proxyArray as? [Proxy]
                    self.updateProxyDataSource()
                    
                case .failure(_):
                    self.errorMessage = "Generic Error Message".localized
                }
            })
        }
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
            
        case "showTokenRequestSegueID":
            if let nextVC = segue.destination as? UINavigationController, let controller = nextVC.viewControllers.first as? TokenRequestListController, let requestsList = tokenRequests {
                 controller.tokenRequests = requestsList
            }
            
        default:
            break
        }
    }
    
    @IBAction func proxySegmentAction(_ sender: UISegmentedControl) {
        tableView?.reloadData()
    }
    
    func updateProxyDataSource() {
        
        proxies = UserManager.shared.proxies ?? []
        if UserManager.shared.hasTestProxyAvailable {
            let testProxy = ProxyService().retrieveTestProxy()
            proxies.insert(testProxy, at: 0)
        }
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
}

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedProxy = filteredProxies[indexPath.item]
        
        if selectedProxy?.isTestProxy == true {
            
            selectedProxy?.proxyDetails?.startDate = Date()
            selectedProxy?.proxyDetails?.endDate   = Date().addingTimeInterval(3600)
            countries = UserManager.shared.proxyCountries ?? []
            self.performSegue(withIdentifier: "FreeProxySegueID", sender: self)
        }
        else {
            performSegue(withIdentifier: "ProxyDetailsSegueiID", sender: self)
        }
    }
}
