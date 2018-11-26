//
//  GroupedMatrixView.swift
//  IPSX
//
//  Created by Calin Chitu on 26/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class GroupedMatrixView: UIView {
    
    @IBOutlet weak var imageR1C1: UIImageView!
    @IBOutlet weak var imageR1C2: UIImageView!
    @IBOutlet weak var imageR2C1: UIImageView!
    @IBOutlet weak var imageR2C2: UIImageView!

    @IBOutlet weak var labelR1C1: UILabel!
    @IBOutlet weak var labelR1C2: UILabel!
    @IBOutlet weak var labelR2C1: UILabel!
    @IBOutlet weak var labelR2C2: UILabel!

    @IBAction func actionR1C1(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        imageR1C1.tintColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        labelR1C1.textColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
    }
    
    @IBAction func actionR1C2(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        imageR1C2.tintColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        labelR1C2.textColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
    }
    
    @IBAction func actionR2C1(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        imageR2C1.tintColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        labelR2C1.textColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
    }
    
    @IBAction func actionR2C2(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        imageR2C2.tintColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        labelR2C2.textColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
    }
}
