//
//  BecomeProviderController.swift
//  IPSX
//
//  Created by Cristina Virlan on 17/09/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class BecomeProviderController: UIViewController {

    @IBOutlet weak var buttonContraintToBottom: NSLayoutConstraint!
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func openInBrowserAction(_ sender: UIButton) {
        print("TODO")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        
        let deviceHeight = UIScreen.main.bounds.height
        if deviceHeight <= 568 {
            buttonContraintToBottom.constant = buttonContraintToBottom.constant - 70
        }
    }
}
