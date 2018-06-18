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
    @IBOutlet weak var statsuImageView: UIImageView?
    @IBOutlet weak var selectedImageView: UIImageView?
    
    private var forceSel = false
    
    func configure(address: EthAddress, forceSelect: Bool = false) {
        forceSel = forceSelect
        aliasLabel.text = address.alias
        addressLabel.text = address.address
        selectedImageView?.isHidden = !isSelected
        if forceSel { selectedImageView?.isHidden = false }
        switch address.validationState {
        case .verified:
            statsuImageView?.image = UIImage(named: "walletAccepted")
        case .pending:
            statsuImageView?.image = UIImage(named: "walletPending")
        case .rejected:
            statsuImageView?.image = UIImage(named: "walletRejected")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedImageView?.isHidden = !selected
        if forceSel { selectedImageView?.isHidden = false }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        selectedImageView?.isHidden = !highlighted
        if forceSel { selectedImageView?.isHidden = false }
    }
}

