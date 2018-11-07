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
    var hasPresentedLegalFlow = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(performActionFor), name: .userDeleted, object: nil)
        if UserManager.shared.hasEthAddress {
            self.setTabBarVisible(visible: false, animated: false)
        }
    }
        
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
                
        if !hasReceivedUsedDeletedNotif && !UserManager.shared.isLoggedIn {
            presentLandingFlow()
        }
        
        if let dashboard = viewControllers?.first as? DashboardViewController {
            dashboard.hideMaskView()
        }
        
        if UserManager.shared.hasPerformedLogout {
            hasPresentedLegalFlow = false
            UserManager.shared.hasPerformedLogout = false
        }
        
        if !hasPresentedLegalFlow && (UserManager.shared.userInfo?.hasOptedForLegal == true && UserManager.shared.company == nil) {
            hasPresentedLegalFlow = true
            self.performSegue(withIdentifier: "CollectLegalDetailsSegueID", sender: nil)
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
        UserManager.shared.logout()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CollectLegalDetailsSegueID" {
            let companyNavController = segue.destination as? UINavigationController
            let companyController = companyNavController?.viewControllers.first as? CompanyDetailsController
            companyController?.onCollectDataComplete = { company in }
        }
    }
}

extension UITabBarController {
    
    private struct AssociatedKeys {
        // Declare a global var to produce a unique address as the assoc object handle
        static var orgFrameView:     UInt8 = 0
        static var movedFrameView:   UInt8 = 1
    }
    
    var orgFrameView:CGRect? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.orgFrameView) as? CGRect }
        set { objc_setAssociatedObject(self, &AssociatedKeys.orgFrameView, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    
    var movedFrameView:CGRect? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.movedFrameView) as? CGRect }
        set { objc_setAssociatedObject(self, &AssociatedKeys.movedFrameView, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let movedFrameView = movedFrameView {
            view.frame = movedFrameView
        }
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        //since iOS11 we have to set the background colour to the bar color it seams the navbar seams to get smaller during animation; this visually hides the top empty space...
        view.backgroundColor =  self.tabBar.barTintColor
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        //we should show it
        if visible {
            tabBar.isHidden = false
            UIView.animate(withDuration: animated ? 0.3 : 0.0) {
                //restore form or frames
                self.view.frame = self.orgFrameView!
                //errase the stored locations so that...
                self.orgFrameView = nil
                self.movedFrameView = nil
                //...the layoutIfNeeded() does not move them again!
                self.view.layoutIfNeeded()
            }
        }
            //we should hide it
        else {
            //safe org positions
            orgFrameView   = view.frame
            // get a frame calculation ready
            let offsetY = self.tabBar.frame.size.height
            movedFrameView = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offsetY)
            //animate
            UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
                self.view.frame = self.movedFrameView!
                self.view.layoutIfNeeded()
            }) {
                (_) in
                self.tabBar.isHidden = true
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return orgFrameView == nil
    }
}
