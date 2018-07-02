//
//  TabBarController.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var hasReceivedUsedDeletedNotif = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(performActionFor), name: .userDeleted, object: nil)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

        // When closing the app from Add Eth Address screen after Login, the user remains loggedIn
        if !UserManager.shared.hasEthAddress {
            UserManager.shared.logout()
        }
        if !hasReceivedUsedDeletedNotif && !UserManager.shared.isLoggedIn {
            presentLandingFlow()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .userDeleted, object: nil)
    }
    
    @objc fileprivate func performActionFor(_ notification: NSNotification) {
        
        if notification.name == .userDeleted {
            
            DispatchQueue.main.async {
                
                UserManager.shared.logout()
                self.hasReceivedUsedDeletedNotif = true
                self.navigationController?.dismiss(animated: true, completion: nil)
                self.presentLandingFlow()
            }
        }
    }

    func presentLandingFlow() {
        self.performSegue(withIdentifier: "showLandingSegueID", sender: nil)
    }
    
    @IBAction func unwindToTabBar(segue:UIStoryboardSegue) { }
}
