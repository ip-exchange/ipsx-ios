//
//  DashboardViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    let cellID = "ProxyActivationDetailsCellID"
    let transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO (CVI): add activity indicator
        
        ProxyService().retrieveProxiesForCurrentUser(completionHandler: { result in
            //TODO (CVI): remove activity indicator
            
            switch result {
                
            case .success(let success):
                
                guard (success as? Bool) == true else {
                    return
                    //TODO (CVI): error handling
                }
                print("SUCCESS!")
                
            case .failure(let error):
                
                //TODO (CVI): error handling
                
                if let error = error as? CustomError {
                    switch error {
                    case .expiredToken:
                        print("Perform login automatically to generate a new token")
                        
                    default:
                        print("TODO")
                    }
                }
            }
        })
    }
    
}

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProxyActivationDetailsCell
        cell.cellContentView.shadow = true
        cell.cellProgress1.transform = transform
        cell.cellProgress2.transform = transform
       return cell
    }
}


