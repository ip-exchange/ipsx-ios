//
//  RoundedButton.swift
//  IPSX
//
//  Created by Cristina Virlan on 17/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    
    var isBordered: Bool?
    
    @IBInspectable open var borderColor: UIColor = UIColor.black {
        didSet {
            if isBordered == true {
                self.layer.borderWidth = 1
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }
    
    @IBInspectable open var bordered: Bool = false {
        didSet {
            isBordered = bordered
        }
    }
    
    open override func layoutSubviews() {
        
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }
}


