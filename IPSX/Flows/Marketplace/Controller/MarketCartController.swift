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
    @IBOutlet weak var editButton: UIButton!
    
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
    
    @IBAction func editAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        tableView.reloadData()
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
    
    func performViewCartRequest() {
        
        //loadingView?.startAnimating()
        MarketplaceService().viewCart(completionHandler: { result in
            
            //self.loadingView?.stopAnimating()
            switch result {
            case .success(_):
                print("yey")
                
            case .failure(let error):
                
                print("lala", error)
//                self.handleError(error, requestType: RequestType.viewCart, completion: {
//                    self.performViewCartRequest()
//                })
            }
        })
    }
}

extension MarketCartController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProxyManager.shared.allOffers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MarketCell
        cell.onDelete = { offer in
            ProxyManager.shared.allOffers = ProxyManager.shared.allOffers?.filter { $0.id != offer.id }
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        }
        cell.cellContentView.shadow = true
        let progress = Double(arc4random_uniform(100))
        cell.progressView.progress = progress
        cell.progressLabel.text = "\(Int(progress))%"
        if let offer =  ProxyManager.shared.allOffers?[indexPath.item] {
            cell.configure(offer: offer, editMode: editButton.isSelected)
        }
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
