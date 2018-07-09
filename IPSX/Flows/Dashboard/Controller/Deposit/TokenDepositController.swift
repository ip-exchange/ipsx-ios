//
//  TokenDepositController.swift
//  IPSX
//
//  Created by Calin Chitu on 04/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class TokenDepositController: UIViewController {
    
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var selectedWalletAlias: UILabel!
    @IBOutlet weak var selectedWalletAddress: UILabel!
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var proxyPacksTableView: UITableView!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownArrow: UIImageView!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var walletImageView: UIImageView!
    @IBOutlet weak var dropDownTopConstraint: NSLayoutConstraint! {
        didSet { topConstraint = dropDownTopConstraint }
    }

    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    var ethAdresses: [EthAddress] = []
    var deposits: [Deposit] = []
    private var selectedAddress: EthAddress?
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var deposit: Deposit?
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    var selectedPack: ProxyPack?
    let cellID = "ProxyPackCellID"
    var proxyPacks : [ProxyPack]? {
        didSet {
            DispatchQueue.main.async {
                self.proxyPacksTableView.reloadData()
            }
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        
        for deposit in deposits {
            
            guard deposit.status != "pending" else {
                self.errorMessage = "Create Deposit Not Possible Message".localized
                return
            }
        }
        
        let invalidInputs = ["0", ".", ".0", "0.", "0.0"]
        if invalidInputs.contains(amountTextField.text ?? "0") {
            
            self.errorMessage = "Deposit Wrong Amount Error Message".localized
            
        } else {
            let ethID = selectedAddress?.ethID ?? 0
            let amount = amountTextField.text ?? ""
            createDeposit(ethID: ethID, amount: amount)
        }
    }
    
    func createDeposit(ethID: Int, amount: String) {
        
        loadingView?.startAnimating()
        TokenDepositService().createDeposit(ethID: ethID, amount: amount, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(let deposit):
                
                self.deposit = deposit as? Deposit
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showSummarySegueID", sender: self)
                }
                
            case .failure(let error):
                
                self.handleError(error, requestType: .createDeposit, completion: {
                    self.createDeposit(ethID: ethID, amount: amount)
                })
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createKeyboardToolbar()
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: dropdownView, text: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAndSetDefaultAddres()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        if UserManager.shared.proxyPacks == nil {
            retrieveProxyPackages()
        } else {
            proxyPacks = UserManager.shared.proxyPacks
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSummarySegueID" {
            let dest = segue.destination as? TokenDepositSummaryController
            dest?.presentedFromCreateScreen = true
            dest?.deposit = self.deposit
        }
    }

    func retrieveProxyPackages() {
        
        loadingView?.startAnimating()
        ProxyService().retrieveProxyPackages(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let packages):
                UserManager.shared.proxyPacks = packages as? [ProxyPack]
                self.proxyPacks = UserManager.shared.proxyPacks
                
            case .failure(let error):
                self.handleError(error, requestType: .retrieveProxyPackages, completion: {
                    self.retrieveProxyPackages()
                })
            }
        })
    }

    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else {
                self.toast?.hideToastAlert()
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropdownAction(_ sender: Any) {
        updateDropDown(visible: true)
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
    
    private func updateUI() {
        tableViewBottomConstraint.constant = tableView.frame.size.height
        tableViewTopConstraint.constant = -tableView.frame.size.height
    }
    
    private func updateSelectedAddresUI(ethAddres: EthAddress) {
        selectedWalletAlias.text   = ethAddres.alias
        selectedWalletAddress.text = ethAddres.address
    }
    
    fileprivate func updateDropDown(visible: Bool) {
        view.endEditing(true)
        dropDownTopConstraint.constant     = visible ? -100 : 0
        tableViewBottomConstraint.constant = visible ?    0 : tableView.frame.size.height
        tableViewTopConstraint.constant    = visible ?    0 : -tableView.frame.size.height
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.5, options: [], animations: {
            self.view?.layoutIfNeeded()
            self.proxyPacksTableView.alpha = visible ? 0 : 1
            self.tableView.alpha    = visible ? 1 : 0
            self.dropdownView.alpha = visible ? 0 : 1
            self.backButton.alpha   = visible ? 0 : 1
            self.submitButton.alpha = visible ? 0 : 1
        }, completion: { completed in
        })
    }
    
    private func createKeyboardToolbar() {
        let tooBar: UIToolbar = UIToolbar()
        tooBar.barStyle = UIBarStyle.default
        tooBar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done".localized, style: UIBarButtonItemStyle.done, target: self, action: #selector(TokenDepositController.donePressed))]
        tooBar.sizeToFit()
        amountTextField.inputAccessoryView = tooBar
    }
    
    @objc func donePressed () {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

extension TokenDepositController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == proxyPacksTableView {
            return proxyPacks?.count ?? 0
        } else {
            return ethAdresses.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == proxyPacksTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProxyPackCell
            cell.cellContentView.shadow = true
            
            if let proxyPack = proxyPacks?[indexPath.row] {
                cell.configure(proxyPack: proxyPack)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: EthWalletCell.cellID, for: indexPath) as! EthWalletCell
            let ethAddress = ethAdresses[indexPath.item]
            cell.configure(address: ethAddress)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
        headerView.backgroundColor = .clear
        return headerView
    }

}

extension TokenDepositController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        if tableView == proxyPacksTableView {
            tableView.deselectRow(at: indexPath, animated: false)
            
            if let proxyPack = proxyPacks?[indexPath.row] {
                self.selectedPack = proxyPack
            }
            
             let packagePrice = Int(self.selectedPack?.price ?? "0") ?? 0
            amountTextField.text = "\(packagePrice)"
        } else {
            selectedAddress = ethAdresses[indexPath.item]
            if let validAddres = selectedAddress {
                UserDefaults.standard.storeDelfaultETHAddressID(ethAddressID: validAddres.ethID)
                updateSelectedAddresUI(ethAddres: validAddres)
            }
            updateDropDown(visible: false)
        }
    }
}

extension TokenDepositController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension TokenDepositController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension TokenDepositController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
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
