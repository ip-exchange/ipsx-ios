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

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBAction func registerWithFacebookAction(_ sender: UIButton) {
        facebookLogin()
    }
    
    var fbToken: String = ""
    let chooseDestinyFlowID = "showChooseDestinySegueID"
    
    func facebookLogin() {
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self, completion: { loginResult in
            
            switch loginResult {
                
            case .failed(_):
                self.errorMessage = "Facebook Login Error Message".localized
                
            case .cancelled:
                print("User cancelled login.")
                
            case .success(_,  _, let accessToken):
                self.fbToken = accessToken.authenticationToken
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.chooseDestinyFlowID, sender: nil)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == chooseDestinyFlowID {
            let destination = segue.destination as? ChooseDestinyViewController
            destination?.fbToken = fbToken
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundImageView.removeParticlesAnimation()
    }

}

extension RegisterOptionsController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}
