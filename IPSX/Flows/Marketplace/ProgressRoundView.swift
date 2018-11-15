//
//  ProgressRoundView.swift
//  IPSX
//
//  Created by Calin Chitu on 15/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressRoundView: UIView {

    var progress: Double = 0 {
        didSet {
            setProgress(progress)
        }
    }
    
    private var lineWidth: CGFloat { return frame.size.width / 8 }
    private var subCircle1: CAShapeLayer!

    override public var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    
    override public class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
        self.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        setPath()
    }
    
    private func setProgress(_ progress: Double) {
        
        if subCircle1 != nil { subCircle1.removeFromSuperlayer() }
        
        let convertedProgress = progress * Double.pi * 2 / 100
        let centery: CGPoint = CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.width / 2)
        let path2 = UIBezierPath(arcCenter: centery, radius: (layer.frame.size.width / 2) - (lineWidth / 2), startAngle: CGFloat(0), endAngle: CGFloat(convertedProgress), clockwise: true)
        
        subCircle1 = CAShapeLayer()
        subCircle1.frame = layer.bounds
        subCircle1.path = path2.cgPath
        subCircle1.fillColor = nil
        subCircle1.strokeColor = UIColor.progressGreen.cgColor
        subCircle1.lineWidth = lineWidth
       layer.addSublayer(subCircle1)

    }
    private func setPath() {
        
        let centery: CGPoint = CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.width / 2)
        let path1 = UIBezierPath(arcCenter: centery, radius: (layer.frame.size.width / 2) - (lineWidth / 2), startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: false)

        layer.fillColor = nil
        layer.strokeColor = UIColor.progressGray.cgColor
        layer.lineWidth = lineWidth
        layer.path = path1.cgPath
        
     }
}
