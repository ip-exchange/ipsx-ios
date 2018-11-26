//
//  GroupedOptionsView.swift
//  IPSX
//
//  Created by Calin Chitu on 25/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class GroupedOptionsView: UIView {

    @IBOutlet weak var firstOption: UIButton!
    @IBOutlet weak var secondOption: UIButton!

    @IBAction func firstOptionAction(_ sender: UIButton) {
        firstOption.isSelected = !firstOption.isSelected
        if firstOption.isSelected {
            secondOption.isSelected = false
        }
    }
    
    @IBAction func secondOptionAction(_ sender: Any) {
        secondOption.isSelected = !secondOption.isSelected
        if secondOption.isSelected {
            firstOption.isSelected = false
        }
    }
    
}
