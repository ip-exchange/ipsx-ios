//
//  LandingViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 17/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    
    @IBAction func signUpEmailTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func unwindToMain(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        
        let deviceHeight = UIScreen.main.bounds.height
        labelTopConstraint.constant = (deviceHeight - bottomView.frame.height) / 2
    }
    
}
