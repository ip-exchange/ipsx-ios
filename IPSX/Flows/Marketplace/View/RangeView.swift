//
//  RangeView.swift
//  IPSX
//
//  Created by Calin Chitu on 23/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

@IBDesignable
class RangeView: UIView {

    @IBOutlet weak var rangeSlider: RangeSlider?
    @IBOutlet weak var minValueLabel: UILabel?
    @IBOutlet weak var minUnitLabel: UILabel?
    @IBOutlet weak var maxValueLabel: UILabel?
    @IBOutlet weak var maxUnitLabel: UILabel?

    @IBInspectable open var unit: String = ""
    @IBInspectable open var decimals: Int = 0 {
        didSet { if decimals < 0 { decimals = 0 } }
    }
    @IBInspectable open var minVal: Double = 100
    @IBInspectable open var maxVal: Double = 1000
    @IBInspectable open var lowerVal: Double = 200
    @IBInspectable open var upperVal: Double = 800
    @IBInspectable open var minDelta: Double = 100

    override func awakeFromNib() {
        
        rangeSlider?.backgroundColor = .clear
        rangeSlider?.lowerValue = (lowerVal / maxVal)
        rangeSlider?.upperValue = (upperVal / maxVal)
        rangeSlider?.minimumValue = (minVal / maxVal)
        rangeSlider?.maximumValue = 1
        rangeSlider?.minRangeDelta = (minDelta / maxVal)
        minValueLabel?.text = String(format: "%.\(self.decimals)f", lowerVal)
        minUnitLabel?.text = unit
        maxValueLabel?.text = String(format: "%.\(self.decimals)f", upperVal)
        maxUnitLabel?.text = unit
        
        rangeSlider?.onValueChange = { lower, upper in
             let low = lower * self.maxVal
            let  up = upper * self.maxVal

            self.minValueLabel?.text = String(format: "%.\(self.decimals)f", low)
            self.maxValueLabel?.text = String(format: "%.\(self.decimals)f", up)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rangeSlider?.updateLayerFrames()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
}
