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
        case pending
        case unavailable
        case unknown
    }
    
    @IBOutlet weak var canceledView: UIView?
    @IBOutlet weak var activeView: UIView?
    @IBOutlet weak var expiredView: UIView?
    @IBOutlet weak var pendingView: UIView?
    @IBOutlet weak var unavailableView: UIView?
    @IBOutlet weak var unknownView: UIView?

    public var currentState: CellState = .active {
        didSet {
            
            activeView?.isHidden      = true
            canceledView?.isHidden    = true
            expiredView?.isHidden     = true
            pendingView?.isHidden     = true
            unavailableView?.isHidden = true
            unknownView?.isHidden     = true
            
            switch currentState {
            case .active:   activeView?.isHidden         = false
            case .canceled: canceledView?.isHidden       = false
            case .expired:  expiredView?.isHidden        = false
            case .pending:  pendingView?.isHidden        = false
            case .unavailable: unavailableView?.isHidden = false
            case .unknown:  unknownView?.isHidden        = false
          }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }
}
