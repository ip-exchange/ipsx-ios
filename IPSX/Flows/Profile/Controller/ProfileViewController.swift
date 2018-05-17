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
        configureUI()
        refreshProfileUI()
        refreshETHaddressesUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedAddress = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topImageView.createParticlesAnimation()
    }
    
    private func configureUI() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.layer.borderColor  = UIColor.darkBlue.cgColor
        userImageView.layer.borderWidth  = 1
    }
    
    func refreshProfileUI() {
        
        DispatchQueue.main.async {
            if let firstName = self.userInfo?.firstName {
                let lastName = self.userInfo?.lastName ?? ""
                self.usernameLabel.text = firstName + " " + lastName
            }
        }
    }
    
    func refreshETHaddressesUI() {
        
        DispatchQueue.main.async {
            if let addresses = UserManager.shared.ethAddresses {
                self.ethAdresses = addresses
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            
        case "showProfileSegueID":
            let navController = segue.destination as? UINavigationController
            let editProfileVC = navController?.viewControllers.first as? EditProfileController
            editProfileVC?.onDismiss = { hasUpdatedProfile in
                
                if hasUpdatedProfile {
                    
                    self.loadingView.startAnimating()
                    UserInfoService().retrieveUserInfo(completionHandler: { result in
                        
                        self.loadingView.stopAnimating()
                        
                        switch result {
                        case .success(let user):
                            UserManager.shared.userInfo = user as? UserInfo
                            self.refreshProfileUI()
                        
                        case .failure(_):
                            self.errorMessage = "Refresh Data Error Message".localized
                        }
                    })
                }
            }
        case "walletViewIdentifier", "walletAddIdentifier":
            let addController = segue.destination as? AddWalletController
            addController?.ethereumAddress = selectedAddress
            addController?.onDismiss = { hasUpdatedETH in
                
                if hasUpdatedETH {
                    
                    self.loadingView.startAnimating()
                    
                    UserInfoService().retrieveETHaddresses(completionHandler: { result in
                        
                        self.loadingView.stopAnimating()
                        
                        switch result {
                        case .success(let ethAddresses):
                            UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                            self.refreshETHaddressesUI()
                            
                        case .failure(_):
                            self.errorMessage = "Refresh Data Error Message".localized
                        }
                    })
                }
            }
        default:
            break
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
}

extension ProfileViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topImageView)
        }
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
                        self.loadingView.startAnimating()
                        
                        UserInfoService().retrieveETHaddresses() { result in
                            
                            self.loadingView.stopAnimating()
                            
                            switch result {
                            case .success(let ethAddresses):
                                UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                                self.refreshETHaddressesUI()
                                
                            case .failure(_):
                                self.errorMessage = "Refresh Data Error Message".localized
                            }
                        }
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
