//
//  TokenRequestListController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

//TODO: logic for datasource & update 

class TokenRequestListController: UIViewController {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var noItemsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let cellID = "TokenRequestCellID"
    var tokenRequests: [TokenRequest] = []
    
    //TODO (CC): implement toast alert
    var errorMessage: String? {
        didSet {
            //toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    //TODO (CC): add loadingView
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateUI() {
        
        DispatchQueue.main.async {
            self.tokenRequests = UserManager.shared.tokenRequests ?? []
            self.separatorView.isHidden = self.tokenRequests.count < 1
            self.noItemsLabel.isHidden = self.tokenRequests.count > 0
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
      
        if UserManager.shared.tokenRequests == nil {
            
            //self.loadingView.startAnimating()
            ProxyService().getTokenRequestList(completionHandler: { result in
                
                //self.loadingView.stopAnimating()
                switch result {
                case .success(let tokenRequests):
                    UserManager.shared.tokenRequests = tokenRequests as? [TokenRequest]
                    self.updateUI()
                    
                case .failure(_):
                    self.errorMessage = "Generic Error Message".localized
                }
            })
        }
        else {
            updateUI()
        }
    }
    
    private func ethAddressFor(tokenRequest: TokenRequest) -> EthAddress? {
        var ethAddress: EthAddress? = nil
        if let addresses = UserManager.shared.ethAddresses {
            let matches = addresses.filter { return $0.ethID == tokenRequest.ethID }
            if matches.count == 1 {
                ethAddress = matches.first
            }
        }
        return ethAddress
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCreateTokenSegueID" {
            let nextVC = segue.destination as? TokenRequestController
            nextVC?.onDismiss = { hasSubmittedRequest in
                
                if hasSubmittedRequest {
                
//                    self.loadingView.startAnimating()
                    
                    ProxyService().getTokenRequestList(completionHandler: { result in
                        
//                      self.loadingView.stopAnimating()
                        
                        switch result {
                        case .success(let tokenRequests):
                            UserManager.shared.tokenRequests = tokenRequests as? [TokenRequest]
                            self.updateUI()
                            
                        case .failure(_):
                            self.errorMessage = "Refresh Data Error Message".localized
                        }
                    })
                }
            }
        }
    }
}

extension TokenRequestListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokenRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TokenRequestCell
        let tokenRequest = tokenRequests[indexPath.item]
        let address      = ethAddressFor(tokenRequest: tokenRequest)
        cell.configure(tokenRequest: tokenRequest, ethAdrress: address)
        
        return cell
    }
}


class TokenRequestCell: UITableViewCell {
    
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    @IBOutlet weak var canceledView: RoundedView!
    
    func configure(tokenRequest: TokenRequest, ethAdrress: EthAddress? = nil) {
        if let date = tokenRequest.created {
            dateLabel.text = DateFormatter.dateStringForTokenRequests(date: date)
        }
        aliasLabel.text = ethAdrress?.alias ?? "My Address".localized
        quantityLabel.text = "Requested: " + tokenRequest.amount
        pendingView.isHidden   = tokenRequest.status != "pending"
        completedView.isHidden = tokenRequest.status != "completed"
        canceledView.isHidden  = tokenRequest.status != "rejected"
    }
}
