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

    public func setProgress(upProgress: Float? = nil, downProgress: Float? = nil) {
        if let up = upProgress {
            cellProgressUp?.progress = up
            cellProgressUpBis?.progress = up
        }
        if let down = downProgress {
            cellProgressDown?.progress = down
            cellProgressDownBis?.progress = down
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        setProgress(downProgress: 0.0)
        setProgress(upProgress: 0.0)
    }
}
