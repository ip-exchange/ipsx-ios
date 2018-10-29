//
//  AppDelegate.swift
//  IPSX
//
//  Created by Cristina Virlan on 15/03/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import CVINetworkingFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if UserDefaults.standard.isFreshInstall() {
            UserManager.shared.logout()
        }
        setKeychainAccessGroup()
        UserManager.shared.retrieveAccessDetails()
        let _ = ReachabilityManager.shared
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        ReachabilityManager.shared.stopNotifier()
        FBSDKAppEvents.activateApp()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        switch url.host {
            
        case "registration":
            let url = url.absoluteURL
            let accessToken = url.valueOf("token") ?? ""
            let userId = url.valueOf("uid") ?? ""
            
            //Store access details in keychain
            UserManager.shared.storeAccessDetails(userId: userId, accessToken: accessToken)
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialVC = mainStoryboard.instantiateInitialViewController() as? UINavigationController
            let loadingVC = initialVC?.viewControllers.first as? LoadingViewController
            loadingVC?.hasPerformedAutologin = true
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialVC
            self.window?.makeKeyAndVisible()
            
            return true
            
        case "delete":
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialVC = mainStoryboard.instantiateInitialViewController() as? UINavigationController
            let loadingVC = initialVC?.viewControllers.first as? LoadingViewController
            loadingVC?.hasConfirmedDeleteAccount = true
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialVC
            self.window?.makeKeyAndVisible()
            
            return true
            
        default:
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        }
    }
    
    func setKeychainAccessGroup() {
        
        guard let appIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as? String, let bundleId = Bundle.main.bundleIdentifier else{
            print("Keychain Error: could not load AppIdentifierPrefix used for setting group access")
            return
        }
        let keychainGroup = appIdentifierPrefix + bundleId
        KeychainWrapper.accessGroup = keychainGroup
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        ReachabilityManager.shared.stopNotifier()

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        ReachabilityManager.shared.stopNotifier()
        ReachabilityManager.shared.startNotifier()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        ReachabilityManager.shared.stopNotifier()
        ReachabilityManager.shared.startNotifier()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

