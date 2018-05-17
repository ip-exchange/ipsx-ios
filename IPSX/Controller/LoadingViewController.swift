//
//  LoadingViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 15/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    let dispatchGroup = DispatchGroup()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
        if UserManager.shared.isLoggedIn {
            initDataForCurrentUser()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                self.performSegue(withIdentifier: "TabbarSegueID", sender: self)
            }
        }
    }
    
    func initDataForCurrentUser() {
        
        userCountryList()
        ethAddresses()
        userInfo()
        proxies()
        tokenRequestList()
        proxyCountryList()
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "TabbarSegueID", sender: self)
            }
        }
    }
    
    func userCountryList() {
        
        dispatchGroup.enter()
        UserInfoService().getUserCountryList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            switch result {
            case .success(let countryList):
                UserManager.shared.userCountries = countryList as? [[String: String]]
                DispatchQueue.main.async { self.progressView.progress += 0.16 }
            case .failure(_):
                print("Generic Error Message".localized)
            }
        })
    }
    
    func ethAddresses() {
        
        dispatchGroup.enter()
        UserInfoService().retrieveETHaddresses(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let ethAddresses):
                UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                DispatchQueue.main.async { self.progressView.progress += 0.16 }

            case .failure(_):
                print("Generic Error Message".localized)
            }
        })
    }
    
    func userInfo() {
        
        dispatchGroup.enter()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                DispatchQueue.main.async { self.progressView.progress += 0.16 }

            case .failure(_):
                print("Generic Error Message".localized)
            }
        })
    }
    
    func proxies() {
        
        dispatchGroup.enter()
        ProxyService().retrieveProxiesForCurrentUser(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
                
            case .success(let proxyArray):
                UserManager.shared.proxies = proxyArray as? [Proxy]
                DispatchQueue.main.async { self.progressView.progress += 0.16 }

            case .failure(_):
                print("Generic Error Message".localized)
            }
        })
    }
    
    func tokenRequestList() {
        
        dispatchGroup.enter()
        ProxyService().getTokenRequestList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let tokenRequests):
                UserManager.shared.tokenRequests = tokenRequests as? [TokenRequest]
                DispatchQueue.main.async { self.progressView.progress += 0.16 }

            case .failure(_):
                print("Generic Error Message".localized)
            }
        })
    }
    
    func proxyCountryList() {
        
        dispatchGroup.enter()
        ProxyService().getProxyCountryList(completionHandler: { result in
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let countryList):
                UserManager.shared.proxyCountries = countryList as? [String]
                DispatchQueue.main.async { self.progressView.progress +=  0.16 }

            case .failure(_):
                print("Generic Error Message".localized)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
