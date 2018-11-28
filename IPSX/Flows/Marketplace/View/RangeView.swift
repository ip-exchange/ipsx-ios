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
    
    private var actualLow: Double = 0
    private var actualUp: Double = 0
    
    public var onNewState: ((_ state: Bool, _ values: (low: Double, high: Double))->())?
    
    public func reset() {
        
        rangeSlider?.trackHighlightTintColor = UIColor(white: 221/255.0, alpha: 0.5)
        rangeSlider?.lowerValue = (lowerVal / maxVal)
        rangeSlider?.upperValue = (upperVal / maxVal)
        minValueLabel?.text = String(format: "%.\(self.decimals)f", lowerVal)
        maxValueLabel?.text = String(format: "%.\(self.decimals)f", upperVal)
        actualLow = lowerVal
        actualUp = upperVal
    }
    
    public func updateSlider(lower: Double, upper: Double, moveThumbs: Bool = true) {
        
        let low = lower * self.maxVal
        let  up = upper * self.maxVal
        
        if moveThumbs {
            rangeSlider?.lowerValue = (low / maxVal)
            rangeSlider?.upperValue = (up / maxVal)
        }
        
        self.actualLow = low
        self.actualUp = up
        
        self.minValueLabel?.text = String(format: "%.\(self.decimals)f", low)
        self.maxValueLabel?.text = String(format: "%.\(self.decimals)f", up)
        
        if low == self.minVal, up == self.maxVal {
            self.rangeSlider?.trackHighlightTintColor = UIColor(white: 221/255.0, alpha: 0.5)
            self.onNewState?(false, (self.actualLow, self.actualUp))
        } else {
            self.rangeSlider?.trackHighlightTintColor = UIColor.lightBlue
            self.onNewState?(true, (self.actualLow, self.actualUp))
        }
    }
    
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
        rangeSlider?.trackHighlightTintColor = UIColor(white: 221/255.0, alpha: 0.5)
        
        actualLow = lowerVal
        actualUp = upperVal
        
        rangeSlider?.onValueChange = { lower, upper in
            self.updateSlider(lower: lower, upper: upper, moveThumbs: false)
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
