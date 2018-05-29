//
//  NewProxyController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class NewProxyController: UIViewController {
    
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
    
    let dataSource = [ProxyPack(iconName: "PackCoins", name: "Silver Pack", noOfMB: "100", duration: "60 min", price: "50"),
                      ProxyPack(iconName: "PackCoins", name: "Gold Pack", noOfMB: "500", duration: "1 day", price: "100"),
                      ProxyPack(iconName: "PackCoins", name: "Platinum Pack", noOfMB: "1024", duration: "7 days", price: "200"),
                      ProxyPack(iconName: "PackCoins", name: "Diamond Pack", noOfMB: "10240", duration: "30 days", price: "500")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
        balance = "\(userInfo?.balance ?? 0)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        countries = UserManager.shared.proxyCountries
    }
    
    func getProxyCountryList() {
        
        loadingView.startAnimating()
        ProxyService().getProxyCountryList(completionHandler: { result in
            
            self.loadingView.stopAnimating()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveUserInfo()
        
        // After Logout
        if UserManager.shared.proxyCountries == nil {
            getProxyCountryList()
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
            self.performSegue(withIdentifier: self.countrySelectionID, sender: nil)
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

