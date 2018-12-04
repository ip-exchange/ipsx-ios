//
//  DoubleProgressView.swift
//  IPSX
//
//  Created by Calin Chitu on 04/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DoubleProgressView: UIView {
    
    @IBOutlet weak var cellProgressUp: UIProgressView?
    @IBOutlet weak var cellProgressUpBis: UIProgressView?
    @IBOutlet weak var cellProgressDown: UIProgressView?
    @IBOutlet weak var cellProgressDownBis: UIProgressView?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }
}
