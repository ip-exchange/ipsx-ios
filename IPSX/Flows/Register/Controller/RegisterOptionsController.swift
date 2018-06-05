//
//  RegisterOptionsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import FacebookLogin

class RegisterOptionsController: UIViewController {

     //TODO (CC): loadingView & errorMessage
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBAction func registerWithFacebookAction(_ sender: UIButton) {
        facebookLogin()
    }
    
    var fbToken: String = ""
    let registrationTermsFlowID = "showRegistrationTermsSegueID"
    
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
                self.fbToken = accessToken.authenticationToken
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.registrationTermsFlowID, sender: nil)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == registrationTermsFlowID {
            let destination = segue.destination as? RegisterTermsController
            destination?.fbToken = fbToken
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
    }

}
