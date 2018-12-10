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
        
        if let url = URL(string: Url.becomeProviderUrl) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
