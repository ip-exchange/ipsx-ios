//
//  MarketTutorialController.swift
//  IPSX
//
//  Created by Calin Chitu on 15/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class MarketTutorialController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func gotItAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showAgainAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UserDefaults.standard.setMarketTutorialChecked(sender.isSelected)
    }
    
}
