//
//  WithdrawalListController.swift
//  IPSX
//
//  Created by Calin Chitu on 05/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//


import UIKit
import IPSXNetworkingFramework

class WithdrawalListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var withdrawals: [Withdrawal] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getWithdrawals()
    }
    
    private func getWithdrawals() {
        loadingView.startAnimating()
        FundsService().getWithdrawalsList(completionHandler: { result in
            DispatchQueue.main.async { self.loadingView.stopAnimating() }
            switch result {
            case .success(let withdrawals):
                self.withdrawals = withdrawals as? [Withdrawal] ?? []
                self.withdrawals = self.withdrawals.sorted() {
                    let d1 = $0.createdAt ?? Date()
                    let d2 = $1.createdAt ?? Date()
                    return d1.compare(d2) == .orderedDescending
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.getWithdrawals()
                })
            }
        })
    }

    
    @IBAction func newWithdrawAction(_ sender: Any) {
        DispatchQueue.main.async { self.performSegue(withIdentifier: "ValidWalletsListSegueID", sender: self) }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToWithdrawsList(segue:UIStoryboardSegue) {}
}

extension WithdrawalListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return withdrawals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WithdrawallCell.cellID, for: indexPath) as! WithdrawallCell
        let withdrawal = withdrawals[indexPath.item]
        cell.configure(withdrawal: withdrawal)
        return cell
    }
}

extension WithdrawalListController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}


extension WithdrawalListController: ErrorPresentable {
    
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
