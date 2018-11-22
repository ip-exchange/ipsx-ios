//
//  MarketCheckoutController.swift
//  IPSX
//
//  Created by Calin Chitu on 22/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class MarketCheckoutController: UIViewController {

    
    @IBOutlet weak var activationInfoAttributedLabel: UILabel!
    
    private let unwindToMarketSegueID = "UnwindToMarketSegueID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedString = NSMutableAttributedString(string: "The proxies will be activated in \nmaximum 5 minutes after purchase!", attributes: [
            .font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            .foregroundColor: UIColor(white: 153.0 / 255.0, alpha: 1.0)
            ])
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14.0, weight: .bold), range: NSRange(location: 34, length: 17))
        activationInfoAttributedLabel.attributedText = attributedString
    }
    
    @IBAction func rentAction(_ sender: Any) {
        self.performSegue(withIdentifier: unwindToMarketSegueID, sender: self)
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
