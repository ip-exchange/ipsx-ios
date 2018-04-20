//
//  UIColor+extensions.swift
//  IPSX
//
//  Created by Cristina Virlan on 17/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

// MARK:- Custom colors
public extension UIColor {
    
    static var darkGray: UIColor {
        return UIColor(red: 42.0 / 255.0, green: 42.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0)
    }
    
    static var darkRed: UIColor {
        return UIColor(red: 207.0 / 255.0, green: 14.0 / 255.0, blue: 14.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var silver: UIColor {
        return UIColor(red: 206.0 / 255.0, green: 212.0 / 255.0, blue: 218.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var warmGrey: UIColor {
        return UIColor(white: 112.0 / 255.0, alpha: 1.0)
    }
}

// MARK:- Styled color
public extension UIColor {
    
    static var inputNormal: UIColor {
        return .darkGray
    }
    
    static var inputError: UIColor {
        return .darkRed
    }
}
