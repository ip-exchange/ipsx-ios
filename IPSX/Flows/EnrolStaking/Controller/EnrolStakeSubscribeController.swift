//
//  EnrolStakeSubscribeController.swift
//  IPSX
//
//  Created by Calin Chitu on 28/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EnrolStakeSubscribeController: UIViewController {

    @IBOutlet weak var joinStakingButton: RoundedButton!
    @IBOutlet weak var tableView: UITableView!
    
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    var ethAdresses: [EthAddress] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadValidAddresses()
    }
    
    private func loadValidAddresses() {
        if let addresses = UserManager.shared.ethAddresses {
            ethAdresses = addresses.filter { return  $0.validationState == .verified }
            tableView.reloadData()
        }
    }

    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension EnrolStakeSubscribeController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ethAdresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EthWalletCell.cellID, for: indexPath) as! EthWalletCell
        let ethAddress = ethAdresses[indexPath.item]
        cell.configure(address: ethAddress)
        return cell
    }
}

extension EnrolStakeSubscribeController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
