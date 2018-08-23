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
    
    @IBAction func unwindToMain(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
   }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundImageView.removeParticlesAnimation()
    }
    
    func configureUI() {
        
        let deviceHeight = UIScreen.main.bounds.height
        labelTopConstraint.constant = ((deviceHeight - bottomView.frame.height) / 2) - 30
    }
    
    @IBAction func unwindToLandingConstroller(segue:UIStoryboardSegue) { }
}
