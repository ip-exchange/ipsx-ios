//
//  WithdrawalListController.swift
//  IPSX
//
//  Created by Calin Chitu on 05/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//


import UIKit


class WithdrawalListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var contentSeparator: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    
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

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSeparator.isHidden = true
        noDataLabel.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getWithdrawals()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
    }

    private func getWithdrawals() {
        
        self.timer?.invalidate()
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
                    self.contentSeparator.isHidden = self.withdrawals.count < 1
                    self.noDataLabel.isHidden = self.withdrawals.count > 0
                    if self.withdrawals.filter({ $0.status == "pending" }).count > 0 {
                        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
                    }
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getWithdrawalsList, completion: {
                    self.getWithdrawals()
                })
            }
        })
    }

    @objc func updateData() {
        getWithdrawals()
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
