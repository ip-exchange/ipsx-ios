//
//  UITableView+extensions.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

extension UITableView {
    
    func standardHeaderView(withTitle title: String,
                            textColor: UIColor = .black,
                            font: UIFont = UIFont.systemFont(ofSize: 18, weight: .semibold),
                            textAlignment: NSTextAlignment = .left,
                            labelPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 0)) -> UIView {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: sectionHeaderHeight))
        containerView.backgroundColor = UIColor.clear
        
        let label = UILabel(frame: containerView.bounds)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = textAlignment
        label.textColor = textColor
        label.font = font
        label.text = title
        
        containerView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: labelPadding.top).isActive = true
        label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: labelPadding.bottom).isActive = true
        label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: labelPadding.left).isActive = true
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: labelPadding.right).isActive = true
        
        return containerView
    }
}
