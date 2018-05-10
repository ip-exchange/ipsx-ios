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
    var hasTriedToRefreshToken = false
    var showLoader = true
    
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
       }
    }
    let cellID = "ActivationDetailsCellID"
    var selectedProxy: Proxy? = nil
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
     }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: slidableView, text: "Invalid Credentials")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showLoader { loadingView.startAnimating() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedProxy = nil
        tokensAmountLabel.text = "\(userInfo?.ballance ?? 0)"
        showLoader = true
        if UserManager.shared.isLoggedIn {
            
            executeRequests() { success in
                
                DispatchQueue.main.async {
                    self.tokensAmountLabel.text = "\(self.userInfo?.ballance ?? 0)"
                    self.loadingView.stopAnimating()
                    self.showLoader = false
                }
                if !success {
                    //TODO (CVI): redirect to login somehow nice
                    //Temporary solution: display generic error
                    self.errorMessage = "Generic Error Message".localized
                }
            }
        }
    }
    
    func executeRequests(completion:@escaping (Bool) -> ()) {
        
        if UserManager.shared.userInfo == nil {
            
            UserInfoService().retrieveUserInfo(completionHandler: { result in
                switch result {
                    
                case .failure(let error):
                    
                    switch error {
                    case CustomError.expiredToken:
                        
                        if !self.hasTriedToRefreshToken {
                            self.generateNewToken(completion: completion)
                        }
                        else {
                            completion(false)
                        }
                    default:
                        completion(false)
                    }
                    
                case .success(_):
                    self.getProxyDetails(completion: completion)
                }
            })
        }
        else {
            self.getProxyDetails(completion: completion)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProxyDetailsSegueiID", let proxyDetailsController = segue.destination as? ProxyDetailsViewController {
            proxyDetailsController.proxy = selectedProxy
        }
    }
    
    func getProxyDetails(completion:@escaping (Bool) -> ()) {
        
        ProxyService().retrieveProxiesForCurrentUser(completionHandler: { result in
            
            switch result {
                
            case .success(let proxyArray):
                
                guard let proxyArray = proxyArray as? [Proxy] else {
                    completion(false)
                    return
                }
                self.proxies = proxyArray
                self.checkForTestProxyAvailability()
                completion(true)
                
            case .failure(let error):
                
                switch error {
                case CustomError.expiredToken:
                    
                    if !self.hasTriedToRefreshToken {
                        self.generateNewToken(completion: completion)
                    }
                    else {
                        completion(false)
                    }
                default:
                    completion(false)
                }
            }
        })
    }
    
    func generateNewToken(completion:@escaping (Bool) -> ()) {
        
        hasTriedToRefreshToken = true
        LoginService().getNewAccessToken(completionHandler: { result in
            
            switch result {
                
            case .success(_):
                self.getProxyDetails(completion: completion)
                
            case .failure(_):
                completion(false)
            }
        })
    }
    
    func checkForTestProxyAvailability() {
        
        if UserManager.shared.userInfo?.proxyTest == "" {
            let testProxyPack = ProxyPack()
            let testProxyActivationDetails = ProxyActivationDetails(usedMB: "0", remainingDuration: "20 min", status: "active".localized)
            let testProxy = Proxy(proxyPack: testProxyPack, proxyDetails: testProxyActivationDetails, isTestProxy: true)
            proxies.insert(testProxy, at: 0)
        }
    }
    
    @IBAction func proxySegmentAction(_ sender: UISegmentedControl) {
        tableView?.reloadData()
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
        performSegue(withIdentifier: "ProxyDetailsSegueiID", sender: self)
    }
}
