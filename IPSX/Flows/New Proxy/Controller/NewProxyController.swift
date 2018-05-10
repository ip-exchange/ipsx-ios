//
//  NewProxyController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class NewProxyController: UIViewController {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    let cellID = "ProxyPackCellID"
    let countrySelectionID = "CountrySearchSegueID"
    var countries: [String] = []

    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    let dataSource = [ProxyPack(iconName: "PackCoins", name: "Silver Pack", noOfMB: "100", duration: "60 min", price: "50"),
                      ProxyPack(iconName: "PackCoins", name: "Gold Pack", noOfMB: "500", duration: "1 day", price: "100"),
                      ProxyPack(iconName: "PackCoins", name: "Platinum Pack", noOfMB: "1024", duration: "7 days", price: "200"),
                      ProxyPack(iconName: "PackCoins", name: "Diamond Pack", noOfMB: "10240", duration: "30 days", price: "500")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "Dummy")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == countrySelectionID {
            let navController = segue.destination as? UINavigationController
            let destinationVC = navController?.viewControllers.first as? SearchViewController
            destinationVC?.isProxyFlow = true
            destinationVC?.countries = countries
        }
    }
    
    func retrieveProxyCountries(completion:@escaping ([String]?) -> ()) {
        
        ProxyService().getProxyCountryList(completionHandler: { result in
            
            var proxyCountries: [String]?
            switch result {
            case .success(let countryList):
                
                if let countries = countryList as? [String] {
                    proxyCountries = countries
                }
                else {
                    self.errorMessage = "Generic Error Message".localized
                }
                
            case .failure(_):
                self.errorMessage = "Generic Error Message".localized
            }
            completion(proxyCountries)
        })
    }
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

extension NewProxyController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        //TODO (CVI): Determine when should we load the countries
        //Temp solution:
        
        retrieveProxyCountries() { countries in
            
            if let countries = countries {
                
                self.countries = countries
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.countrySelectionID, sender: nil)
                }
            }
        }
    }
}

extension NewProxyController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.addSubview(toastView)
        }
    }
}
