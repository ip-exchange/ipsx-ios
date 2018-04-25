//
//  NewProxyController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class NewProxyController: UIViewController {
    let cellID = "NewProxyCellID"

}

extension NewProxyController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! NewProxyCell
        cell.cellContentView.shadow = true
        return cell
    }
    
}

class NewProxyCell: UITableViewCell {
    
    @IBOutlet weak var cellContentView: RoundedView!
}
