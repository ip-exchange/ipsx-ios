//
//  UItextField+extensions.swift
//  IPSX
//
//  Created by Calin Chitu on 07/01/2019.
//  Copyright © 2019 Cristina Virlan. All rights reserved.
//

import UIKit

extension UITextField {
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.cut) || action == #selector(UIResponderStandardEditActions.copy)
    }
}
