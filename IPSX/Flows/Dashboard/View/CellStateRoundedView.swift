//
//  CellStateRoundedView.swift
//  IPSX
//
//  Created by Calin Chitu on 04/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class CellStateRoundedView: UIView {
    
    enum CellState {
        case active
        case canceled
        case expired
    }
    
    @IBOutlet weak var canceledView: UIView?
    @IBOutlet weak var activeView: UIView?
    @IBOutlet weak var expiredView: UIView?
    
    public var currentState: CellState = .active {
        didSet {
            switch currentState {
            case .active:
                activeView?.isHidden = false
                canceledView?.isHidden = true
                expiredView?.isHidden = true
            case .canceled:
                canceledView?.isHidden = false
                expiredView?.isHidden = true
                activeView?.isHidden = true
            case .expired:
                expiredView?.isHidden = false
                canceledView?.isHidden = true
                activeView?.isHidden = true
          }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
        self.currentState = .active
    }
}
