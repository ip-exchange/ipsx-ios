//
//  LoginOptionsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit

class LoginOptionsController: UIViewController {

    //TODO (CC): loadingView & errorMessage
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    var dict: [String : AnyObject] = [:]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
    }

    @IBAction func unwindToLoginOptions(segue:UIStoryboardSegue) { }
    
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        
        if let accessToken = FBSDKAccessToken.current() {
            self.executeLogin(withFBtoken: accessToken.tokenString)
        }
        else {
            facebookLogin()
        }
    }
    
    func facebookLogin() {
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: { loginResult in
            
            switch loginResult {
                
            case .failed(_):
                print("fb error")
                //self.errorMessage = "Facebook Login Error Message".localized
                
            case .cancelled:
                print("User cancelled login.")
                
            case .success(_,  _, let accessToken):
                self.executeLogin(withFBtoken: accessToken.authenticationToken)
            }
        })
    }
    
    func executeLogin(withFBtoken fbToken: String) {
        
        //self.loadingView?.startAnimating()
        LoginService().loginWithFB(fbToken: fbToken, completionHandler: { result in
            
            //self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.continueFlow()
                
            case .failure(_):
                //self.errorMessage = "Generic Error Message".localized
                print("error")
            }
        })
    }
    
    func continueFlow() {
        
        UserInfoService().retrieveETHaddresses(completionHandler: { result in
            
            switch result {
                
            case .success(let ethAddresses):
                UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                
                DispatchQueue.main.async {
                    if UserManager.shared.hasEthAddress {
                        self.performSegue(withIdentifier: "showDashboardSegueID", sender: nil)
                    }
                    else {
                        self.performSegue(withIdentifier: "showAddWalletSegueID", sender: nil)
                    }
                }
            case .failure(_):
                print("error")
                //self.errorMessage = "Generic Error Message".localized
            }
        })
    }
    
}
