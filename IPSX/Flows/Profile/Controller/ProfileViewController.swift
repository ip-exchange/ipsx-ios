//
//  ProfileViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    let cellID = "ETHAddressCellID"
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    var ethAdresses: [EthAddress] = []
    var shouldRefresh = false
    
    private var selectedAddress: EthAddress?
    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }

    @IBAction func logoutButtonAction(_ sender: UIButton) {
        
        LoginService().logout(completionHandler: { result in
            switch result {
            case .success(_):
                UserManager.shared.removeUserDetails()
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showLandingSegueID", sender: nil)
                }
            case .failure(_):
                self.errorMessage = "Logout Error Message".localized
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedAddress = nil
        if let addresses = userInfo?.ethAddresses {
            ethAdresses = addresses
            tableView.reloadData()
        } else {
            shouldRefresh = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topImageView.createParticlesAnimation()
        if shouldRefresh {
            shouldRefresh = false
            refreshETHAdresses()
        }
    }
    
    private func updateUI() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.layer.borderColor  = UIColor.darkBlue.cgColor
        userImageView.layer.borderWidth  = 1
        if let firstName = userInfo?.firstName {
            let lastName = userInfo?.lastName ?? ""
            usernameLabel.text = firstName + " " + lastName
        }
    }
    
    private func refreshETHAdresses() {
        loadingView.startAnimating()
        UserInfoService().retrieveETHaddresses() { result in
            DispatchQueue.main.async { self.loadingView.stopAnimating() }
            switch result {
            case .success(let ethAddresses):
                guard let ethAddresses = ethAddresses as? [EthAddress] else { return }
                UserManager.shared.storeEthAddresses(ethAddresses: ethAddresses)
                if let addresses = self.userInfo?.ethAddresses {
                    self.ethAdresses = addresses
                 }
            case .failure(_):
                print("Generic Error Message".localized)
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "walletViewIdentifier", let addController = segue.destination as? AddWalletController {
            addController.ethereumAddress = selectedAddress
            addController.profileContext  = true
            shouldRefresh = true
        }
        if segue.identifier == "walletAddIdentifier", let addController = segue.destination as? AddWalletController {
            addController.profileContext  = true
            shouldRefresh = true
       }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ethAdresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EthWalletCell
        let ethAddress = ethAdresses[indexPath.item]
        cell.configure(address: ethAddress)
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddress = ethAdresses[indexPath.item]
        performSegue(withIdentifier: "walletViewIdentifier", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return ethAdresses.count > 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let ethAddress = ethAdresses[indexPath.item]
            loadingView.startAnimating()
            UserInfoService().updateETHaddress(requestType: .deleteEthAddress, ethID: ethAddress.ethID) { result in
                
                DispatchQueue.main.async { self.loadingView.stopAnimating() }
                
                switch result {
                    
                case .success(_):
                    
                    DispatchQueue.main.async {
                        self.ethAdresses.remove(at: indexPath.item)
                        self.refreshETHAdresses()
                    }
                    
                case .failure(let error):
                    
                    switch error {
                    case CustomError.ethAddressAlreadyUsed:
                        self.errorMessage = "ETH Address Delete Failed Error Message".localized
                    default:
                        self.errorMessage = "Generic Error Message".localized
                    }
                }
            }
        }
    }
}

extension ProfileViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topImageView)
        }
    }
}

class EthWalletCell: UITableViewCell {
    
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statsuImageView: UIImageView!
    
    func configure(address: EthAddress) {
        aliasLabel.text = address.alias
        addressLabel.text = address.address
        switch address.validationState {
        case .verified:
            statsuImageView.image = UIImage(named: "walletAccepted")
        case .pending:
            statsuImageView.image = UIImage(named: "walletPending")
        case .rejected:
            statsuImageView.image = UIImage(named: "walletRejected")
        }
    }
    
}
