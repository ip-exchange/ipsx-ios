//
//  ChooseDestinyViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 11/09/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ChooseDestinyViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    @IBAction func bbackAction(_ sender: UIButton) {
        
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func requesterAction(_ sender: UIButton) {
        performSegue(withIdentifier: registerTermsFlowID, sender: DestinyType.requester)
    }
    
    @IBAction func providerAction(_ sender: UIButton) {
        performSegue(withIdentifier: registerTermsFlowID, sender: DestinyType.provider)
    }
    
    let registerTermsFlowID = "showRegistrationTermsSegueID"
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        backgroundImageView.removeParticlesAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
    }
    
    var topConstraint: NSLayoutConstraint?
    var fbToken: String = ""
    var userCredentials: [String: String] = ["email": "", "pass": ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == registerTermsFlowID, let destiny = sender as? DestinyType {
            
            let nextVC = segue.destination as? RegisterTermsController
            nextVC?.userDestiny = destiny
            nextVC?.userCredentials = userCredentials
            nextVC?.fbToken = fbToken
        }
    }

}
