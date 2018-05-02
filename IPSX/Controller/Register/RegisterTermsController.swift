//
//  RegTermsConntroller.swift
//  IPSX
//
//  Created by Calin Chitu on 20/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class RegisterTermsController: UIViewController {

    @IBOutlet weak var readWPLabel: UILabel!
    @IBOutlet weak var registerButton: RoundedButton!
    
    private var statesDic: [String : Bool] = [:]
    var userCredentials: [String: String] = ["email": "", "pass": ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.isEnabled = false
     }
    
    @IBAction func checkboxButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let titleText = sender.title(for: .selected) {
            statesDic[titleText] = sender.isSelected
        }
        var allAgreed = true
        if statesDic.values.contains(false) || statesDic.values.count < 4 {
            allAgreed = false
        }
        registerButton.isEnabled = allAgreed
    }
    
    @IBAction func registerButtonAction(_ sender: UIButton) {
        
        //TODO (CVI): add activity indicator
        
        IPService().getPublicIPAddress(completion: { error, ipAddress in
            
            guard let ipAddress = ipAddress, error == nil else {
                //TODO (CVI): remove activity indicator
                //TODO (CVI): error handling
                return
            }
            
            if let email = self.userCredentials["email"], let pass = self.userCredentials["pass"] {
                RegisterService().registerUser(email: email, password: pass, ip: ipAddress, completionHandler: { result in
                    
                    //TODO (CVI): remove activity indicator
                    
                    switch result {
                        
                    case .success(_):
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "showRegConfirmationSegueID", sender: nil)
                        }
                        
                    case .failure(let error):
                        print(error)
                        //TODO (CVI): error handling
                    }
                })
            }
        })
    }
}
