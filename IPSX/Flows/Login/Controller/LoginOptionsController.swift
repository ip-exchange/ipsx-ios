//
//  LoginOptionsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import FacebookLogin

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
        facebookLogin()
    }
    
    func facebookLogin() {
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: { loginResult in
            
            switch loginResult {
                
            case .failed(_):
                print("remove comment")
                //self.errorMessage = "Facebook Login Error Message".localized
                
            case .cancelled:
                print("User cancelled login")
                
            case .success(_,  _, let accessToken):
                self.executeLogin(withFBtoken: accessToken.authenticationToken)
            }
        })
    }
    
    func executeLogin(withFBtoken fbToken: String) {
        
        //self.loadingView?.startAnimating()
        SocialIntegrationService().facebook(requestType: .fbLogin, fbToken: fbToken, completionHandler: { result in
            
            //self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.continueFlow()
                
            case .failure(let error):
                self.handleError(error, requestType: .fbLogin)
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
            case .failure(let error):
                self.handleError(error, requestType: .getEthAddress)
            }
        })
    }
}

extension LoginOptionsController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
        switch requestType {
            
        case .fbLogin:
            
            switch error {
            case CustomError.notFound:
                print("remove comment")
                //self.errorMessage = "User Not Registered Error Message".localized
                
            default:
                print("remove comment")
                //self.errorMessage = "Generic Error Message".localized
            }
        default:
            print("remove comment")
            //self.errorMessage = "Generic Error Message".localized
        }
    }
}
