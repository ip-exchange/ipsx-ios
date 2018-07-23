//
//  AppDelegate.swift
//  IPSX
//
//  Created by Cristina Virlan on 15/03/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if UserDefaults.standard.isFreshInstall() {
            UserManager.shared.logout()
        }
        setKeychainAccessGroup()
        UserManager.shared.retrieveAccessDetails()
        let _ = ReachabilityManager.shared
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
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
            //TODO: remove Abort delete from Settings
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
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

