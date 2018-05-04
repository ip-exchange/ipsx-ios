//
//  CustomLoadingView.swift
//  IPSX
//
//  Created by Calin Chitu on 03/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class CustomLoadingView: UIView {
    
    public func startAnimating() {
        guard subCircle1 != nil, subCircle2 != nil else { return }
        self.alpha = 1
        rotationAnimation(duration: 2, layer: layer)
        rotationAnimation(duration: 1, layer: subCircle1)
        rotationAnimation(duration: 2, layer: subCircle2)
    }
    
    public func stopAnimating() {
        self.alpha = 0
        guard subCircle1 != nil, subCircle2 != nil else { return }
        layer.removeAllAnimations()
        subCircle1.removeAllAnimations()
        subCircle2.removeAllAnimations()
    }
    
    var lineWidth: CGFloat { return frame.size.width / 33 }
    
    private var subCircle1: CAShapeLayer!
    private var subCircle2: CAShapeLayer!
    
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
        self.alpha = 0
        setPath()
    }
    
    private func setPath() {
        
        let centery: CGPoint = CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.width / 2)
        let path1 = UIBezierPath(arcCenter: centery, radius: (layer.frame.size.width / 2) - (lineWidth / 2), startAngle: 0, endAngle: CGFloat(Double.pi), clockwise: true)
        let path2 = UIBezierPath(arcCenter: centery, radius: (layer.frame.size.width / 2) - (lineWidth / 2) - (lineWidth * 2), startAngle: 0, endAngle: CGFloat(Double.pi), clockwise: true)
        let path3 = UIBezierPath(arcCenter: centery, radius: (layer.frame.size.width / 2) - (lineWidth / 2) - (lineWidth * 4), startAngle: 0, endAngle: CGFloat(Double.pi), clockwise: true)
        
        layer.fillColor = nil
        layer.strokeColor = UIColor.darkBlue.cgColor
        layer.lineWidth = lineWidth
        layer.path = path1.cgPath
        
        subCircle1 = CAShapeLayer()
        subCircle1.frame = layer.bounds
        subCircle1.path = path2.cgPath
        subCircle1.fillColor = nil
        subCircle1.strokeColor = UIColor.disabledGrey.cgColor
        subCircle1.lineWidth = lineWidth
        layer.addSublayer(subCircle1)
        
        subCircle2 = CAShapeLayer()
        subCircle2.frame = layer.bounds
        subCircle2.path = path3.cgPath
        subCircle2.fillColor = nil
        subCircle2.strokeColor = UIColor.darkRed.cgColor
        subCircle2.lineWidth = lineWidth
        layer.addSublayer(subCircle2)
    }
    
    func rotationAnimation(duration: CFTimeInterval, layer: CAShapeLayer) {
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue =  Double.pi * 2.0
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: "spin")
    }
    
}