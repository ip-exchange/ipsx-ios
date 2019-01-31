//
//  WithdrawWaletsListController.swift
//  IPSX
//
//  Created by Calin Chitu on 10/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class WithdrawWaletsListController: UIViewController {
    
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
    private var validAdddresses: [EthAddress] {
        return ethAdresses.filter() { $0.validationState == EthAddressState.verified }
    }
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
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AmountSegueID" {
            let dest = segue.destination as? WithdrawAmountController
            dest?.selectedAddress = selectedAddress
        }
    }
    
}

extension WithdrawWaletsListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return validAdddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EthWalletCell.cellID, for: indexPath) as! EthWalletCell
        let ethAddress = validAdddresses[indexPath.item]
        cell.configure(address: ethAddress)
        return cell
    }
}

extension WithdrawWaletsListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddress = validAdddresses[indexPath.item]
        DispatchQueue.main.async { self.performSegue(withIdentifier: "AmountSegueID", sender: self) }
    }
}

extension WithdrawWaletsListController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension WithdrawWaletsListController: ErrorPresentable {
    
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
            default:
                self.errorMessage = "Generic Error Message".localized
            }
        }
    }
}
