//
//  NewProxyController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class NewProxyController: UIViewController {
    
    let cellID = "ProxyPackCellID"
    
    let dataSource = [ProxyPack(iconName: "PackCoins", name: "Silver Pack", noOfMB: 100, duration: "60 min", price: 50),
                      ProxyPack(iconName: "PackCoins", name: "Gold Pack", noOfMB: 500, duration: "1 day", price: 100),
                      ProxyPack(iconName: "PackCoins", name: "Platinum Pack", noOfMB: 1024, duration: "7 days", price: 200),
                      ProxyPack(iconName: "PackCoins", name: "Diamond Pack", noOfMB: 10240, duration: "30 days", price: 500)]
}

extension NewProxyController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProxyPackCell
        cell.cellContentView.shadow = true
        
        if dataSource.count > indexPath.row {
            cell.configure(proxyPack: dataSource[indexPath.row])
        }
        return cell
    }
    
}


