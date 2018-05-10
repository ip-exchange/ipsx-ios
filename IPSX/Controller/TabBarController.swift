//
//  TabBarController.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if !UserManager.shared.isLoggedIn {
            presentLandingFlow()
        } else {
            UserInfoService().retrieveETHaddresses(completionHandler: { result in
                
                switch result {
                case .success(let ethAddresses):
                    guard let ethAddresses = ethAddresses as? [EthAddress] else { return }
                    UserManager.shared.storeEthAddresses(ethAddresses: ethAddresses)
                    
                case .failure(_):
                    print("Generic Error Message".localized)

                }
            })
        }
    }
        
    func presentLandingFlow() {
        self.performSegue(withIdentifier: "showLandingSegueID", sender: nil)
    }
    
    @IBAction func unwindToTabBar(segue:UIStoryboardSegue) { }
}
