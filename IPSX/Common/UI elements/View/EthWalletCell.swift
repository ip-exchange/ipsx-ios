//
//  EthWalletCell.swift
//  IPSX
//
//  Created by Calin Chitu on 22/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EthWalletCell: UITableViewCell {
    
    static let cellID = "ETHAddressCellID"
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statsuImageView: UIImageView!
    
    func configure(address: EthAddress) {
        aliasLabel.text = address.alias
        addressLabel.text = address.address
        switch address.validationState {
        case .verified:
            statsuImageView.image = UIImage(named: "walletAccepted")
        case .pending:
            statsuImageView.image = UIImage(named: "walletPending")
        case .rejected:
            statsuImageView.image = UIImage(named: "walletRejected")
        }
    }
}

