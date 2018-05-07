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
    var errorMessage: String? {
        didSet {
            //TODO (CVI): Show toast alert
            print(errorMessage ?? "")
        }
    }
    let cellID = "ActivationDetailsCellID"
    let transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
    var proxies: [Proxy] = []
    
    var filteredProxies: [Proxy] {
        get {
            let filterString = proxiesSegmentController.selectedSegmentIndex == 0 ? "active".localized : "expired".localized
            return proxies.filter { $0.proxyDetails?.status == filterString }
         }
        set { }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //TODO (CVI): add activity indicator
        
        if UserManager.shared.isLoggedIn() {
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
                    self.updateUI()
                    
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
    }
    
    func updateUI() {
        
        DispatchQueue.main.async {
            let filterString = self.proxiesSegmentController.selectedSegmentIndex == 0 ? "active".localized : "expired".localized
            self.filteredProxies = self.proxies.filter { $0.proxyDetails?.status == filterString }
            self.tableView?.reloadData()
        }
    }
    
    func checkForTestProxyAvailability() {
        
        if UserManager.shared.userInfo?.proxyTest == "" {
            let testProxyPack = ProxyPack()
            let testProxyActivationDetails = ProxyActivationDetails(status: "active".localized)
            let testProxy = Proxy(proxyPack: testProxyPack, proxyDetails: testProxyActivationDetails)
            proxies.insert(testProxy, at: 0)
        }
    }
    
    @IBAction func proxySegmentAction(_ sender: UISegmentedControl) {
        tableView?.reloadData()
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


