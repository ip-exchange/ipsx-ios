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

    @IBOutlet weak var buttonR1C1: UIButton!
    @IBOutlet weak var buttonR1C2: UIButton!
    @IBOutlet weak var buttonR2C1: UIButton!
    @IBOutlet weak var buttonR2C2: UIButton!
    
    public var onNewState: ((_ state: Bool, _ values: (r1c1: Bool, r1c2: Bool, r2c1: Bool, r2c2: Bool))->())?
    
    public func reset() {
        buttonR1C1.isSelected = false
        buttonR1C2.isSelected = false
        buttonR2C1.isSelected = false
        buttonR2C2.isSelected = false
        imageR1C1.tintColor = UIColor.darkGray
        labelR1C1.textColor = UIColor.darkGray
        imageR1C2.tintColor = UIColor.darkGray
        labelR1C2.textColor = UIColor.darkGray
        imageR2C1.tintColor = UIColor.darkGray
        labelR2C1.textColor = UIColor.darkGray
        imageR2C2.tintColor = UIColor.darkGray
        labelR2C2.textColor = UIColor.darkGray
        onNewState?(false, (false, false, false, false))
    }

    @IBAction func actionR1C1(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        imageR1C1.tintColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        labelR1C1.textColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        onNewState?(isAnySelected(), (buttonR1C1.isSelected, buttonR1C2.isSelected, buttonR2C1.isSelected, buttonR2C2.isSelected))
    }
    
    @IBAction func actionR1C2(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        imageR1C2.tintColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        labelR1C2.textColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        onNewState?(isAnySelected(), (buttonR1C1.isSelected, buttonR1C2.isSelected, buttonR2C1.isSelected, buttonR2C2.isSelected))
    }
    
    @IBAction func actionR2C1(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        imageR2C1.tintColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        labelR2C1.textColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        onNewState?(isAnySelected(), (buttonR1C1.isSelected, buttonR1C2.isSelected, buttonR2C1.isSelected, buttonR2C2.isSelected))
    }
    
    @IBAction func actionR2C2(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        imageR2C2.tintColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        labelR2C2.textColor = sender.isSelected ? UIColor.lightBlue : UIColor.darkGray
        onNewState?(isAnySelected(), (buttonR1C1.isSelected, buttonR1C2.isSelected, buttonR2C1.isSelected, buttonR2C2.isSelected))
    }
    
    private func isAnySelected() -> Bool {
        return buttonR1C1.isSelected || buttonR1C2.isSelected || buttonR2C1.isSelected || buttonR2C2.isSelected
    }
}
