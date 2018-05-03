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
        
        if !UserManager.shared.isLoggedIn() {
            presentLandingFlow()
        }
    }
    
    @IBAction func unwindToTabbar(segue:UIStoryboardSegue) { }
    
    func presentLandingFlow() {
        self.performSegue(withIdentifier: "showLandingSegueID", sender: nil)
    }
}
