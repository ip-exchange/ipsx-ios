//
//  WalletsListController.swift
//  IPSX
//
//  Created by Calin Chitu on 12/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class WalletsListController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableTopSeparator: UIView!
    @IBOutlet weak var noWalletHelpLabel: UILabel!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }

    var ethAdresses: [EthAddress] = []
    private var selectedAddress: EthAddress?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        retrieveETHaddresses()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedAddress = nil
        refreshETHaddressesUI()
    }
    
    private func configureUI() {
        tableView.tableFooterView = UIView()
    }

    func refreshETHaddressesUI() {
        
        DispatchQueue.main.async {
            if let addresses = UserManager.shared.ethAddresses {
                self.tableTopSeparator.isHidden = addresses.count < 1
                self.noWalletHelpLabel.isHidden = addresses.count > 0
                self.tableView.isHidden = addresses.count < 1
                self.ethAdresses = addresses
                self.tableView.reloadData()
            }
        }
    }

    func retrieveETHaddresses() {
        
        loadingView?.startAnimating()
        UserInfoService().retrieveETHaddresses(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let ethAddresses):
                UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                self.refreshETHaddressesUI()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getEthAddress, completion: {
                    self.retrieveETHaddresses()
                })
            }
        })
    }
    
    func updateETHaddresses(ethID: Int) {
        
        loadingView?.startAnimating()
        UserInfoService().updateETHaddress(requestType: RequestType.deleteEthAddress, ethID: ethID) { result in
            
            self.loadingView?.stopAnimating()
            
            switch result {
                
            case .success(_):
                self.retrieveETHaddresses()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.deleteEthAddress, completion: {
                    self.updateETHaddresses(ethID: ethID)
                })
            }
        }
    }

    @IBAction func closeButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addWalletAction(_ sender: Any) {
        let maxETHaddresses = UserManager.shared.generalSettings?.maxETHaddresses ?? 5
        let ethAddresses = UserManager.shared.ethAddresses?.count ?? 0
        
        if ethAddresses < maxETHaddresses {
            DispatchQueue.main.async { self.performSegue(withIdentifier: "AddWalletSegueID", sender: self) }
        } else {
            let formatedMessage = String(format: "Max %@ ETH addresses Error Message".localized, "\(maxETHaddresses)")
            self.errorMessage = formatedMessage.localized
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewWalletSegueID" {
            let viewerController = segue.destination as? WalletViewerController
            viewerController?.ethereumAddress = selectedAddress
        }
    }
    
}

extension WalletsListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return ethAdresses.count > 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let address = ethAdresses[indexPath.item]
            if address.status == "locked" {
                toast?.showToastAlert("Address Locked Toast Message".localized, autoHideAfter: 5)
            } else {
                showDeleteConfirmationAlert(index: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ethAdresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EthWalletCell.cellID, for: indexPath) as! EthWalletCell
        let ethAddress = ethAdresses[indexPath.item]
        cell.configure(address: ethAddress)
        return cell
    }
}

extension WalletsListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddress = ethAdresses[indexPath.item]
        DispatchQueue.main.async { self.performSegue(withIdentifier: "ViewWalletSegueID", sender: self) }
    }
}

extension WalletsListController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
    
    private func showDeleteConfirmationAlert(index: IndexPath) {
        let ethAddress = ethAdresses[index.item]
        var alertMessage = ethAddress.address
        if ethAddress.testingEnrollmentDate != nil || ethAddress.stakingEnrollmentDate != nil {
            alertMessage = "Enrolled Address Delete Message".localized
        }
        let alertController = UIAlertController(title: "Delete Address Confirmation Alert Title".localized, message: alertMessage, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .default) { (action:UIAlertAction) in
            self.tableView.reloadData()
        }
        
        let deleteAction = UIAlertAction(title: "Delete".localized, style: .destructive) { (action:UIAlertAction) in
            self.updateETHaddresses(ethID: ethAddress.ethID)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension WalletsListController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
            
        default:
            
            switch requestType {
            case RequestType.userInfo, RequestType.getEthAddress:
                self.errorMessage = "Refresh Data Error Message".localized
            case RequestType.deleteEthAddress:
                self.errorMessage = "ETH Address Delete Failed Error Message".localized
            default:
                self.errorMessage = "Generic Error Message".localized
            }
        }
    }
}
