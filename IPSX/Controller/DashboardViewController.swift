//
//  DashboardViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
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
    var errorMessage: String? {
        didSet {
            //TODO (CVI): Show toast alert
            print(errorMessage ?? "")
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
       }
    }
    let cellID = "ActivationDetailsCellID"
    let transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: slidableView, text: "Invalid Credentials")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //TODO (CVI): add activity indicator
        
        if UserManager.shared.isLoggedIn {
            executeRequests()
        }
    }
    
    func executeRequests() {
        
        /*
            Execute User Info request
         */
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            switch result {
                
            case .failure(let error):
                //TODO (CVI): what should we do if the request for user info fails ?
                print(error)
                self.errorMessage = "Generic Error Message".localized

            case .success(_):
                /*
                    Execute Proxies Request
                 */
                ProxyService().retrieveProxiesForCurrentUser(completionHandler: { result in
                    //TODO (CVI): remove activity indicator
                    
                    switch result {
                        
                    case .success(let proxyArray):
                        
                        guard let proxyArray = proxyArray as? [Proxy] else {
                            self.errorMessage = "Generic Error Message".localized
                            return
                        }
                        self.proxies = proxyArray
                        self.checkForTestProxyAvailability()
                        
                    case .failure(let error):
                        
                        if let error = error as? CustomError {
                            switch error {
                            case .expiredToken:
                                
                                //TODO (CVI) automatically login
                                print("Perform login automatically to generate a new token")
                                
                            default:
                                self.errorMessage = "Generic Error Message".localized
                            }
                        }
                    }
                })
            }
        })
    }
        
    func checkForTestProxyAvailability() {
        
        if UserManager.shared.userInfo?.proxyTest == "" {
            let testProxyPack = ProxyPack()
            let testProxyActivationDetails = ProxyActivationDetails(usedMB: "0", remainingDuration: "20 min", status: "active".localized)
            let testProxy = Proxy(proxyPack: testProxyPack, proxyDetails: testProxyActivationDetails)
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
            view.addSubview(toastView)
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
        cell.cellProgress1.transform = transform
        cell.cellProgress2.transform = transform
        cell.configure(proxy: filteredProxies[indexPath.item])
        
        return cell
    }
}


