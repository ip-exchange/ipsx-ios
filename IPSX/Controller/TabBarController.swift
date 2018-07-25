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
    var hasPerformedAutologin = false
    var hasConfirmedDeleteAccount = false
    var showLandingFromUnwindSegue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(performActionFor), name: .userDeleted, object: nil)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if showLandingFromUnwindSegue {
            showLandingFromUnwindSegue = false
            presentLandingFlow()
            return
        }
        
        if !UserManager.shared.hasEthAddress {
            
            if hasPerformedAutologin {
                self.performSegue(withIdentifier: "showAddWalletSegueID", sender: nil)
            }
            else {
                // When closing the app from Add Eth Address screen after Login -> fresh start
                UserManager.shared.logout()
            }
        }
        
        if !hasReceivedUsedDeletedNotif && !UserManager.shared.isLoggedIn {
            presentLandingFlow()
        }
        
        if hasConfirmedDeleteAccount {
            hasConfirmedDeleteAccount = false
            self.selectedIndex = 2
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .userDeleted, object: nil)
    }
    
    @objc fileprivate func performActionFor(_ notification: NSNotification) {
        
        if notification.name == .userDeleted {
            
            DispatchQueue.main.async {
                
                if !self.hasReceivedUsedDeletedNotif {
                    self.hasReceivedUsedDeletedNotif = true
                    UserManager.shared.logout()
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    self.presentLandingFlow()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.hasReceivedUsedDeletedNotif = false
                }
            }
        }
    }

    func presentLandingFlow() {
        self.performSegue(withIdentifier: "showLandingSegueID", sender: nil)
    }
    
    @IBAction func unwindToTabBar(segue:UIStoryboardSegue) { }
    @IBAction func unwindToTabBarAndShowLanding(segue:UIStoryboardSegue) {
        showLandingFromUnwindSegue = true
        UserManager.shared.logout()
    }

}
