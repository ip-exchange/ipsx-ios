//
//  LoginOptionsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class LoginOptionsController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
    }

    @IBAction func unwindToLoginOptions(segue:UIStoryboardSegue) { }
}
