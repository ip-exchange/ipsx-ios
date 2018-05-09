//
//  ProfileViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let cellID = "ETHAddressCellID"
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        
        //TODO (CVI): perform logout request
        UserManager.shared.removeUserDetails()
        performSegue(withIdentifier: "showLandingSegueID", sender: nil)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProfileWalletCell
        return cell
    }
}

class ProfileWalletCell: UITableViewCell {
    
}
