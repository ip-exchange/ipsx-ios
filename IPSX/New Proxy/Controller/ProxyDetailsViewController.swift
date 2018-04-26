//
//  ProxyDetailsViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProxyDetailsViewController: UIViewController {
    
    let activationDetailsCellID = "ActivationDetailsCellID"
    let pacDetailsCellID = "PACDetailsCellID"
    let detailsCellID = "ProxyDetailsCellD"
    var proxy: Proxy?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let proxyPack = ProxyPack(name: "Silver Pack", noOfMB: 100, duration: "60 min")
        let proxyDetails = ProxyActivationDetails(startDate: Date(), endDate: Date(), country: "Spain", userIP: "192.32.50.101", remainingMB: 10, remainingDuration: "20 min", status: Status.active)
        let proxySetup = ProxySetup(pacLink: "7637653211.pac", proxyIP: "192.100.5.99", proxyPort: "532")
        proxy = Proxy(proxyPack: proxyPack, proxyDetails: proxyDetails, proxySetup: proxySetup)
    }
}

extension ProxyDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        case 2: return 4
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: activationDetailsCellID, for: indexPath) as! ProxyActivationDetailsCell
            guard let proxy = proxy else { return UITableViewCell() }
            cell.configure(proxy: proxy)
            return cell
          
        case 1:
            switch indexPath.row {
                
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: pacDetailsCellID, for: indexPath) as! ProxyDetailsCell
                cell.configure(title: "PAC link", value: proxy?.proxySetup?.pacLink)
                return cell

            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: detailsCellID, for: indexPath) as! ProxyDetailsCell
                cell.configure(title: "IP", value: proxy?.proxySetup?.proxyIP)
                return cell

            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: detailsCellID, for: indexPath) as! ProxyDetailsCell
                cell.configure(title: "Port", value:  proxy?.proxySetup?.proxyPort)
                return cell

            default:
                return UITableViewCell()
            }
            
        case 2:
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
                
            case 3:
                cell.configure(title: "User IP", value:  proxy?.proxyDetails?.userIP)
                return cell
                
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
}

extension ProxyDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 100
        case 1,2:
            return 60
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var title = ""
        switch section {
        case 1: title = "Proxy"
        case 2: title = "Other Details"
        default: return nil
        }
        return tableView.standardHeaderView(withTitle: title)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 1,2: return 60
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        switch section {
        case 2: return 100
        default: return 0.01
        }
    }
}
