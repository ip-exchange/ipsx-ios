//
//  NewProxyController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class NewProxyController: UIViewController {
    
    @IBOutlet weak var currentIpInfoLabel: UILabel!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var tokensAmountLabel: UILabel!
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
    var selectedPack: ProxyPack?
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
    
    let dataSource = [ProxyPack(iconName: "PackCoins", name: "Silver Pack", noOfMB: "100", duration: "60", price: "50"),
                      ProxyPack(iconName: "PackCoins", name: "Gold Pack", noOfMB: "500", duration: "1440", price: "100"),
                      ProxyPack(iconName: "PackCoins", name: "Platinum Pack", noOfMB: "1024", duration: "10080", price: "200"),
                      ProxyPack(iconName: "PackCoins", name: "Diamond Pack", noOfMB: "10240", duration: "43200", price: "500")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentIpInfoLabel.text = "Getting IP info..."
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
        balance = "\(userInfo?.balance ?? 0)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveUserInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        
        // After Logout
        if UserManager.shared.proxyCountries == nil {
            getProxyCountryList()
        }
        updateReachabilityInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        countries = UserManager.shared.proxyCountries
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    

    func updateReachabilityInfo() {
        DispatchQueue.main.async {
            //TODO (CC): get the final texts and localize
            switch ReachabilityManager.shared.connectionType {
            case .wifi, .cellular:
                self.currentIpInfoLabel.text = "Getting IP info..."
                IPService().getPublicIPAddress() { error, ipAddress in
                    DispatchQueue.main.async {
                        if let ip = ipAddress {
                            self.currentIpInfoLabel.text = "The proxy will be locked on your current IP address: " + ip
                        } else {
                            self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
                        }
                    }
                }
            case .none:
                self.currentIpInfoLabel.text = "No internet connection".localized
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
                self.handleError(error, requestType: .getProxyCountryList, completion: {
                    self.getProxyCountryList()
                })
            }
        })
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
                self.currentIpInfoLabel.text = "No internet connection".localized
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
                self.balance = "\(UserManager.shared.userInfo?.balance ?? 0)"
                
            case .failure(let error):
                self.handleError(error, requestType: .userInfo, completion: {
                    self.retrieveUserInfo()
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == countrySelectionID {
            let navController = segue.destination as? UINavigationController
            let destinationVC = navController?.viewControllers.first as? SearchViewController
            destinationVC?.isProxyFlow = true
            destinationVC?.countries = countries
            destinationVC?.proxyPack = selectedPack
        }
    }
}

extension NewProxyController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProxyPackCell
        cell.cellContentView.shadow = true
        
        if dataSource.count > indexPath.row {
            cell.configure(proxyPack: dataSource[indexPath.row])
        }
        return cell
    }
}

extension NewProxyController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
        
        let balance = UserManager.shared.userInfo?.balance ?? 0
        
        //TODO (CVI): dummy price (update after integrating proxy plans API)
        let packagePrice = 0

        if balance >= packagePrice {

            //TODO (CC): get the final texts and localize
            switch ReachabilityManager.shared.connectionType {
            case .wifi:
                if self.dataSource.count > indexPath.row {
                    self.selectedPack = self.dataSource[indexPath.row]
                }
                self.performSegue(withIdentifier: self.countrySelectionID, sender: nil)
            case .cellular:
                self.errorMessage = "Please connect to a WiFi network"
            case .none:
                self.errorMessage = "Not connected"
            }
        }
        else {
            self.errorMessage = "Insufficient Balance Error Message".localized
        }
    }
}

extension NewProxyController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension NewProxyController: ErrorPresentable {

    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {

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

