//
//  EnrolStakeSubscribeController.swift
//  IPSX
//
//  Created by Calin Chitu on 28/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class EnrolStakeSubscribeController: UIViewController {

    @IBOutlet weak var joinStakingButton: RoundedButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topMaskview: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    var ethAdresses: [EthAddress] = []
    var editMode = false
    var onDismiss: ((_ hasUpdatedStaking: Bool)->())?
    var selectedEths: [Int]  {
        var selected: [Int] = []
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for path in selectedIndexPaths {
                let ethAddr = ethAdresses[path.item]
                selected.append(ethAddr.ethID)
            }
        }
        return selected
    }
    
    var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        enrollStaking()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinStakingButton.isEnabled = false
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
        createToastAlert(onTopOf: topMaskview, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        loadValidAddresses()
        if editMode {
            loadingView.startAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if editMode {
            var index = 0
            for validAddres in ethAdresses {
                if validAddres.stakingEnrollmentDate != nil {
                    tableView.selectRow(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .none)
                }
                index += 1
            }
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                self.loadingView.stopAnimating()
            }
        }
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


    private func loadValidAddresses() {
        if let addresses = UserManager.shared.ethAddresses {
            ethAdresses = addresses.filter { return  $0.validationState == .verified }
            tableView.reloadData()
        }
    }

    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func enrollStaking() {
        
        loadingView?.startAnimating()
        EnrollmentService().enrollStaking(ethsArray: selectedEths, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    if self.editMode {
                        UserInfoService().retrieveETHaddresses(completionHandler: { result in
                            switch result {
                            case .success(let ethAddresses):
                                UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                                DispatchQueue.main.async {
                                    self.onDismiss?(true)
                                }

                            case .failure(_): break
                            }
                            DispatchQueue.main.async {
                                if (self.tableView.indexPathsForSelectedRows != nil) {
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    self.parent?.dismiss(animated: true, completion:nil)
                                }
                            }
                       })
                    }
                    else {
                        UserInfoService().retrieveETHaddresses(completionHandler: { result in
                            
                            switch result {
                            case .success(let ethAddresses): UserManager.shared.ethAddresses = ethAddresses as? [EthAddress]
                            case .failure(_): break
                            }
                            
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "showEnrollmentDetailsID", sender: nil)
                            }
                        })
                    }
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.enrollStaking, completion: {
                    self.enrollStaking()
                })
            }
        })
    }
}

extension EnrolStakeSubscribeController: UITableViewDataSource {
    
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

extension EnrolStakeSubscribeController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        if rowIsSelected {
            if editMode {
                joinStakingButton.isEnabled = true
                let title = selectedIndexPaths?.count ?? 0 > 1 ? "Join Staking Program".localized : "Abandon Staking Program".localized
                joinStakingButton.setTitle(title.localized, for: .normal)
            } else {
                joinStakingButton.isEnabled = selectedIndexPaths?.count ?? 0 > 1
            }
            tableView.deselectRow(at: indexPath, animated: true)
            return nil
        } else {
            if editMode {
                joinStakingButton.setTitle("Join Staking Program".localized, for: .normal)
            } else {
                joinStakingButton.isEnabled = true
            }
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        joinStakingButton.isEnabled = selectedIndexPaths != nil
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        joinStakingButton.isEnabled = selectedIndexPaths != nil
    }
}

extension EnrolStakeSubscribeController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension EnrolStakeSubscribeController: ErrorPresentable {
    
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
