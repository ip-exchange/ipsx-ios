//
//  ProviderView.swift
//  IPSX
//
//  Created by Cristina Virlan on 13/09/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

public enum ProviderStatus: String {
    
    case notSubmitted = ""
    case pending      = "pending"
    case accepted     = "accepted"
    case rejected     = "rejected"
    case resubmitted  = "resubmitted"
    case incomplete   = "incomplete"
    case canceled     = "canceled"
}

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
    
    public var subbmissionStatus: ProviderStatus? {
        didSet {
            DispatchQueue.main.async {
                self.configure()
            }
        }
    }
    var view: UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        configure()
    }
      
    func configure() {
        
        guard let subbmissionStatus = subbmissionStatus else { return }
        var imageName = ""
        
        switch subbmissionStatus {
            
        case .notSubmitted:
            titleLabel.text = "Ready to become a Provider".localized
            subtitleLabel.text = "Provider Not Submitted Text".localized
            imageName = "providerNotSubmitted"
            
        case .pending:
            titleLabel.text = "About you as Provider".localized
            subtitleLabel.text = "Provider Pending Text".localized
            imageName = "providerPending"
            
        case .resubmitted:
            titleLabel.text = "About you as Provider".localized
            subtitleLabel.text = "Provider Resubmitted Text".localized
            imageName = "providerPending"
            
        case .accepted:
            titleLabel.text = "About you as Provider".localized
            subtitleLabel.text = "Provider Approved Text".localized
            imageName = "providerApproved"
            
        case .rejected:
            titleLabel.text = "About you as Provider".localized
            subtitleLabel.text = "Provider Rejected Text".localized
            imageName = "providerRejected"
            
        case .canceled:
            titleLabel.text = "About you as Provider".localized
            subtitleLabel.text = "Provider Canceled Text".localized
            imageName = "providerRejected"
            
        case .incomplete:
            titleLabel.text = "About you as Provider".localized
            subtitleLabel.text = "Provider Incomplete Text".localized
            imageName = "providerRejected"
            
        }
        statusImageView.image = UIImage(named: imageName)
        layoutIfNeeded()
    }
}

