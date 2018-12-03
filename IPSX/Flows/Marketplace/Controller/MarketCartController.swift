//
//  MarketCartController.swift
//  IPSX
//
//  Created by Calin Chitu on 21/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class MarketCartController: UIViewController {

    @IBOutlet weak var checkoutButton: RoundedButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noWalletView: RoundedView!
    
    fileprivate let cellID = "MarketCellID"
    private let checkoutSegueID = "CheckoutSegueID"
    private let addWalletSegueID = "AddWalletSegueID"
    
    private var hasWallet: Bool {
        return UserManager.shared.roles?.contains(UserRoles.Requester) ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkoutButton.isEnabled = hasWallet
        noWalletView.isHidden = hasWallet
    }
    
    @IBAction func checkout(_ sender: Any) {
        performSegue(withIdentifier: checkoutSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addWalletSegueID {
            let addWalletController = segue.destination as? WalletAddController
            addWalletController?.shouldPop = true
        }
    }
}

extension MarketCartController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MarketCell
        cell.cellContentView.shadow = true
        let progress = Double(arc4random_uniform(100))
        cell.progressView.progress = progress
        cell.progressLabel.text = "\(Int(progress))%"
        return cell
    }
}

extension MarketCartController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            //self.performSegue(withIdentifier: self.marketItemID, sender: self)
        }
    }
}
