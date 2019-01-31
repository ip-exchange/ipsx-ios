//
//  EnrolForTestingController.swift
//  IPSX
//
//  Created by Calin Chitu on 24/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class EnrolTestSubscribeController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropDownTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var selectedWalletAlias: UILabel!
    @IBOutlet weak var selectedWalletAddress: UILabel!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownArrow: UIImageView!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var walletImageView: UIImageView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    var ethAdresses: [EthAddress] = []
    private var selectedAddress: EthAddress?
    
     var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func appWillEnterForeground() {
        updateReachabilityInfo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        loadAndSetDefaultAddres()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else if self.toast?.currentText == "No internet connection".localized {
                self.toast?.hideToastAlert()
            }
        }
    }
    
    func updateReachabilityInfo() {
        DispatchQueue.main.async {
            if !ReachabilityManager.shared.isReachable() {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else if self.toast?.currentText == "No internet connection".localized {
                self.toast?.hideToastAlert()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? EnrolTestSummaryController {
            dest.enroledAddress = selectedAddress
        }
    }
    
    @IBAction func dropdownAction(_ sender: Any) {
        updateDropDown(visible: true)
    }

    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submitAction(_ sender: UIButton) {
        enrollTesting()
    }
    
    func enrollTesting() {
        
        guard let ethID = selectedAddress?.ethID else {
            self.errorMessage = "Generic Error Message".localized
            return
        }
        loadingView?.startAnimating()
        EnrollmentService().enrollTesting(ethID: ethID) { result in
            
            self.loadingView?.stopAnimating()
            
            switch result {
            case .success(let createdDate):
                
                if let created = createdDate as? Date {
                    self.selectedAddress?.testingEnrollmentDate = created
                }
                
                UserInfoService().retrieveETHaddresses(completionHandler: { result in
                    
                    switch result {
                    case .success(let ethAddresses): UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                    case .failure(_): break
                    }

                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showEnrollmentDetailsID", sender: nil)
                    }
                })

                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.enrollTesting, completion: {
                    self.enrollTesting()
                })
            }
        }
    }

    private func updateUI() {
        tableViewBottomConstraint.constant = tableView.frame.size.height
        tableViewTopConstraint.constant = -tableView.frame.size.height
    }

    private func updateSelectedAddresUI(ethAddres: EthAddress) {
        selectedWalletAlias.text   = ethAddres.alias
        selectedWalletAddress.text = ethAddres.address
        walletImageView.image = UIImage(named: "Wallet")
    }

    private func loadAndSetDefaultAddres() {
        selectedAddress = nil
        if let addresses = UserManager.shared.ethAddresses {
            ethAdresses = addresses.filter { return  $0.validationState == .verified }
            if let defaultAddrID = UserDefaults.standard.loadDelfaultETHAddressID() {
                let matches = ethAdresses.filter { return $0.ethID == defaultAddrID }
                if matches.count == 1 {
                    selectedAddress = matches.first
                } else {
                    selectedAddress = ethAdresses.first
                }
            } else if let firstAddr = ethAdresses.first {
                selectedAddress = firstAddr
            }
            if let validAddress = selectedAddress {
                UserDefaults.standard.storeDelfaultETHAddressID(ethAddressID: validAddress.ethID)
                updateSelectedAddresUI(ethAddres: validAddress)
            } else {
                walletImageView.image = UIImage(named: "walletRejected")
                submitButton.isEnabled = false
            }
            tableView.reloadData()
        }
        if ethAdresses.count < 2 {
            dropdownArrow.isHidden = true
            dropdownButton.isHidden = true
        }
    }
    
    fileprivate func updateDropDown(visible: Bool) {
        dropDownTopConstraint.constant     = visible ? -100 : 0
        tableViewBottomConstraint.constant = visible ?    0 : tableView.frame.size.height
        tableViewTopConstraint.constant    = visible ?    0 : -tableView.frame.size.height
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.5, options: [], animations: {
            self.view?.layoutIfNeeded()
            self.tableView.alpha    = visible ? 1 : 0
            self.dropdownView.alpha = visible ? 0 : 1
            self.backButton.alpha   = visible ? 0 : 1
            self.submitButton.alpha = visible ? 0 : 1
        }, completion: { completed in
        })
    }

}

extension EnrolTestSubscribeController: UITableViewDataSource {
    
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

extension EnrolTestSubscribeController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddress = ethAdresses[indexPath.item]
        if let validAddres = selectedAddress {
            UserDefaults.standard.storeDelfaultETHAddressID(ethAddressID: validAddres.ethID)
            updateSelectedAddresUI(ethAddres: validAddres)
        }
        updateDropDown(visible: false)
    }
}

extension EnrolTestSubscribeController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}


extension EnrolTestSubscribeController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })            
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}
