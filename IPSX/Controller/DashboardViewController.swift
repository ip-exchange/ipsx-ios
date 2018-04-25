//
//  DashboardViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    let cellID = "DashboardCellID"
    let transform = CGAffineTransform(scaleX: 1.0, y: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DashboardCell
        cell.cellContentView.shadow = true
        cell.cellProgress1.transform = transform
        cell.cellProgress2.transform = transform
       return cell
    }
}

class DashboardCell: UITableViewCell {
    
    @IBOutlet weak var cellContentView: RoundedView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellProgress1: UIProgressView!
    @IBOutlet weak var cellProgress2: UIProgressView!
    
}
