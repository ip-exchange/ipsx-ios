//
//  SettingsViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var tokensAmountLabel: UILabel!
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tokensAmountLabel.text = "\(userInfo?.ballance ?? 0)"
    }
}
