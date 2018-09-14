//
//  ProviderView.swift
//  IPSX
//
//  Created by Cristina Virlan on 13/09/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

@IBDesignable
class ProviderView: RoundedView {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBInspectable open var status: String = "" {
        didSet {
            if let providerStatus = ProviderStatus(rawValue: status) {
                subbmissionStatus = providerStatus
            }
        }
    }
    
    var subbmissionStatus: ProviderStatus = .notSubmitted
    var view: UIView!
    
    enum ProviderStatus: String {
        
        case notSubmitted = ""
        case pending      = "pending"
        case approved     = "approved"
        case rejected     = "rejected"
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        configure()
    }
      
    func configure() {
        
        switch subbmissionStatus {
            
        case .notSubmitted:
            titleLabel.text = "Ready to become a Provider".localized
            subtitleLabel.text = "You will need to follow a few more steps".localized
            statusImageView.image = UIImage(named: "providerNotSubmitted")
            
        case .pending:
            titleLabel.text = "About you as Provider".localized
            subtitleLabel.text = "Your petition is being reviewed".localized
            statusImageView.image = UIImage(named: "providerPending")
            
        case .approved:
            titleLabel.text = "About you as Provider".localized
            subtitleLabel.text = "Your petition has been approved".localized
            statusImageView.image = UIImage(named: "providerApproved")
            
        case .rejected:
            titleLabel.text = "About you as Provider".localized
            subtitleLabel.text = "Your petition has been rejected".localized
            statusImageView.image = UIImage(named: "providerRejected")
        }
        layoutIfNeeded()
    }
}

