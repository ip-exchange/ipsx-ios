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

    public var onNewState: ((_ state: Bool, _ values: (first: Bool, second: Bool))->())?
    
    public func updateSelection(first: Bool, second: Bool) {
        firstOption.isSelected = first
        secondOption.isSelected = second
        onNewState?((firstOption.isSelected || secondOption.isSelected), (firstOption.isSelected, secondOption.isSelected))
    }
    
    public func reset() {
        firstOption.isSelected = false
        secondOption.isSelected = false
        onNewState?((firstOption.isSelected || secondOption.isSelected), (firstOption.isSelected, secondOption.isSelected))
    }
    
    @IBAction func firstOptionAction(_ sender: UIButton) {
        firstOption.isSelected = !firstOption.isSelected
        onNewState?((firstOption.isSelected || secondOption.isSelected), (firstOption.isSelected, secondOption.isSelected))
    }
    
    @IBAction func secondOptionAction(_ sender: Any) {
        secondOption.isSelected = !secondOption.isSelected
        onNewState?((firstOption.isSelected || secondOption.isSelected), (firstOption.isSelected, secondOption.isSelected))
    }
    
}
