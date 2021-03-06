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
    
    static var darktext: UIColor {
        return UIColor(white: 17.0 / 255.0, alpha: 1.0)
    }
    
    static var darkRed: UIColor {
        return UIColor(red: 207.0 / 255.0, green: 14.0 / 255.0, blue: 14.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var silver: UIColor {
        return UIColor(red: 206.0 / 255.0, green: 212.0 / 255.0, blue: 218.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var lightBlue: UIColor {
        return UIColor(red: 42.0 / 255.0, green: 172.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var darkBlue: UIColor {
        return UIColor(red: 43.0 / 255.0, green: 131 / 255.0, blue: 167 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var warmGrey: UIColor {
        return UIColor(white: 112.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var disabledGrey: UIColor {
        return UIColor(white: 161.0 / 255.0, alpha: 1.0)
    }

    @nonobjc class var textGrey: UIColor {
        return UIColor(white: 151.0 / 255.0, alpha: 1.0)
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
