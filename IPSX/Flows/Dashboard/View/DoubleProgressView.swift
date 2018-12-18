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

    public func setProgress(upProgress: Float? = nil, downProgress: Float? = nil, animated: Bool = true) {
        if let up = upProgress {
            cellProgressUp?.setProgress(up, animated: animated)
            cellProgressUpBis?.setProgress(up, animated: animated)
        }
        if let down = downProgress {
            cellProgressDown?.setProgress(down, animated: animated)
            cellProgressDownBis?.setProgress(down, animated: animated)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        setProgress(downProgress: 0.0)
        setProgress(upProgress: 0.0)
    }
}
