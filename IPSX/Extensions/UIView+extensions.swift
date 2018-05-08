//
//  UIView+extensions.swift
//  IPSX
//
//  Created by Calin Chitu on 08/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

public extension UIView {
    
    /**
     Returns an UIView from a xib file.
     
     - Parameters:
     - withOwner: The file owner set in the xib file
     - bundle: The bundle for the xib file
     
     - Returns: The top level UIView of the xib file
     */
    public static func viewFromNib(withOwner: UIView, bundle: Bundle) -> UIView {
        
        let nib = UINib(nibName: "\(type(of: withOwner))", bundle: bundle)
        let view = nib.instantiate(withOwner: withOwner, options: nil).first as! UIView
        return view
    }
    
}
