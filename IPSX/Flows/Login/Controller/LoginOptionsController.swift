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

    @IBOutlet weak var backgroundImageView: UIImageView!
    var dict: [String : AnyObject] = [:]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
    }

    @IBAction func unwindToLoginOptions(segue:UIStoryboardSegue) { }
    
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        
        if let accessToken = FBSDKAccessToken.current(){
            print("Already logged in. Access token:",accessToken)
            getFBUserData()
        }
        else {
            facebookLogin()
        }
    }
    
    func facebookLogin() {
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self, completion: { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(_,  _, let accessToken):
                print("FB ACCESS TOKEN:", accessToken)
                self.getFBUserData()
            }
        })
    }
    
    //fetch fb user data
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    print(self.dict)
                }
            })
        }
    }
    
}
