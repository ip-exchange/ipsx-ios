//
//  ProxySummaryViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProxySummaryViewController: UIViewController {
    
    let proxyPackCellID = "ProxyPackCellID"
    let detailsCellID = "ProxyDetailsCellD"
    var proxy: Proxy?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureUI()
        let proxyPack = ProxyPack(iconName: "PackCoins", name: "Silver Pack", noOfMB: 100, duration: "60 min", price: 50)
        let proxyDetails = ProxyActivationDetails(startDate: Date(), endDate: Date(), country: "Spain")
        proxy = Proxy(proxyPack: proxyPack, proxyDetails: proxyDetails)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func configureUI() {
        
        let deviceHeight = UIScreen.main.bounds.height
        if deviceHeight <= 568 {
            bottomConstraint.constant = bottomConstraint.constant - 70
        }
    }
}

extension ProxySummaryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 1
            case 1: return 3
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: proxyPackCellID, for: indexPath) as! ProxyPackCell
            guard let selectedProxyPack = proxy?.proxyPack else { return UITableViewCell() }
            cell.configure(proxyPack: selectedProxyPack)
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: detailsCellID, for: indexPath) as! ProxyDetailsCell
            
            switch indexPath.row {
            case 0:
                let startDate = "20 Apr 2018" //proxy?.proxyDetails?.startDate to String with format dd MMM yyyy
                let startHour = "12:00" //proxy?.proxyDetails?.startDate to String with format HH:mm
                cell.configure(title: "Start Date", value: startDate, additionalDetail: startHour)
                return cell
                
            case 1:
                let endDate = "20 Apr 2018" //proxy?.proxyDetails?.endDate to String with format dd MMM yyyy
                let endHour = "13:00" //proxy?.proxyDetails?.endDate to String with format HH:mm
                cell.configure(title: "End Date", value: endDate, additionalDetail: endHour)
                return cell
                
            case 2:
                cell.configure(title: "Country", value: proxy?.proxyDetails?.country)
                return cell
                
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
        
    }
}

extension ProxySummaryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 88
        case 1:
            return 60
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var title = ""
        switch section {
            case 0: title = "Package"
            case 1: title = "Other Details"
            default: return nil
        }
        return tableView.standardHeaderView(withTitle: title)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}











