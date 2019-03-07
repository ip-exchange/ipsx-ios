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
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var marketplaceImageView: UIImageView!
    
    @IBOutlet weak var welcomeTopLabel: UILabel!
    @IBOutlet weak var registerButton: RoundedButton!
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var viewMarketplaceButton: RoundedButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        outletsLocalisation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
   }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func configureUI() {
        
        let deviceHeight = UIScreen.main.bounds.height
        labelTopConstraint.constant = ((deviceHeight - bottomView.frame.height) / 2) - 30
        let image = UIImage(named: "Technology")?.withRenderingMode(.alwaysTemplate)
        marketplaceImageView.image = image
        marketplaceImageView.tintColor = .white
    }
    
    private func outletsLocalisation() {
        welcomeTopLabel.text = "Welcome to".localized
        registerButton.setTitle("Register".localized, for: .normal)
        loginButton.setTitle("Login".localized, for: .normal)
        viewMarketplaceButton.setTitle("View on Marketplace".localized, for: .normal)
    }
    
    @IBAction func unwindToLandingConstroller(segue:UIStoryboardSegue) { }
    @IBAction func unwindToMain(segue:UIStoryboardSegue) { }
    
}
