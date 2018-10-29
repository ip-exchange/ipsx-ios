//
//  TokenDepositsListController.swift
//  IPSX
//
//  Created by Calin Chitu on 04/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import CVINetworkingFramework

class TokenDepositsListController: UIViewController {

    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var hidableDownView: UIView!
    @IBOutlet weak var topRootView: UIView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var particlesHolder: UIView!
    @IBOutlet weak var amountLabelSmall: UILabel!
    @IBOutlet weak var amountLabelLarge: UILabel!
    @IBOutlet weak var tokenDepositHelpLabel: UILabel!
    @IBOutlet weak var headerSeparatorView: UIView!
    @IBOutlet weak var toastHolderView: UIView!
    @IBOutlet weak var amountLabelYConstraint: NSLayoutConstraint!
    
    
    let maxHeaderHeight: CGFloat = 215;
    let minHeaderHeight: CGFloat = 44;
    var previousScrollOffset: CGFloat = 0;
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    var selectedDeposit: Deposit?

    var deposits: [Deposit]? = [] {
        didSet {
            DispatchQueue.main.async {
                let items = self.deposits?.count ?? 0
                self.tokenDepositHelpLabel.isHidden = items > 0
                self.headerSeparatorView.isHidden = items == 0
            }
        }
    }
    
    var balance: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.amountLabelSmall.text = self.balance
                self.amountLabelLarge.text = self.balance
            }
        }
    }

    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    @IBAction func createDepositAction(_ sender: Any) {
        
        if let deposits = deposits {
            
            for deposit in deposits {
                guard deposit.status != "pending" else {
                    self.errorMessage = "Create Deposit Not Possible Message".localized
                    return
                }
            }
        }
        performSegue(withIdentifier: "createDepositSegueID", sender: self)
    }
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updateHeader()
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
        createToastAlert(onTopOf: toastHolderView, text: "")
        toast?.onShow = {
            self.amountLabelYConstraint.constant = 0
            UIView.animate(withDuration: 0.5) { self.view.layoutIfNeeded() }
            
        }
        toast?.onHide = {
            self.amountLabelYConstraint.constant = -30
            UIView.animate(withDuration: 0.5) { self.view.layoutIfNeeded() }
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        getDepositList()
        self.balance = UserManager.shared.userInfo?.balance?.cleanString ?? "0"
        updateReachabilityInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        particlesHolder.createParticlesAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        particlesHolder.removeParticlesAnimation()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        self.toast?.hideToast()
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

    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeightConstraint.constant - self.minHeaderHeight
        let percentage = openAmount / range
        
        self.titleTopConstraint.constant = -openAmount + 10
        self.hidableDownView.alpha = percentage
        self.particlesHolder.alpha = percentage
    }
    
    private func configureUI() {
        self.headerHeightConstraint.constant = self.maxHeaderHeight
        tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSummarySegueID" {
            let dest = segue.destination as? TokenDepositSummaryController
            dest?.presentedFromCreateScreen = false
            dest?.deposit = self.selectedDeposit
        }
    }
    
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - minHeaderHeight
        
        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func setScrollPosition(_ position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
    
    func getDepositList() {
        
        self.loadingView?.startAnimating()
        TokenDepositService().getDepositList(completionHandler: { result in
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let deposits):
                self.deposits = deposits as? [Deposit]
                self.deposits?.sort { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
                self.updateUI()
                
            case .failure(let error):
                self.handleError(error, requestType: IPRequestType.getDepositList, completion: {
                    self.getDepositList()
                })
            }
        })
    }

    func updateUI() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func unwindToTokenDepositList(segue:UIStoryboardSegue) { }
}


extension TokenDepositsListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deposits?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DepositDetailsCell.cellID, for: indexPath) as! DepositDetailsCell
        if let deposit = deposits?[indexPath.item] {
            cell.configure(deposit: deposit)
        }
        return cell
    }
}

class DepositDetailsCell: UITableViewCell {
    
    static let cellID = "DepositDetailsCellID"
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    @IBOutlet weak var canceledView: RoundedView!
    @IBOutlet weak var expiredView: RoundedView!
    @IBOutlet weak var walletAliasLabel: UILabel!
    
    func configure(deposit: Deposit) {
        if let watchDate = deposit.watchUntil, let createdDate = deposit.createdAt {
            dateLabel.text = DateFormatter.dateStringForTokenRequests(date: createdDate)
            
            if deposit.status == "pending" {
                if watchDate.timeIntervalSince(Date()) > 0 {
                    let remainingDuration = watchDate.timeIntervalSince(Date())
                    let components = DateFormatter.secondsToDaysHoursMinutes(seconds: Int(remainingDuration))
                    let remainigDuartionString = DateFormatter.readableDaysHoursMinutes(components:components)
                    dateLabel.text = String(format: "Time Remaining %@".localized, "\(remainigDuartionString)")
                }
            }
        }
        
        quantityLabel.text = deposit.status == "complete" ? "Received".localized : "Requested".localized
        pendingView.isHidden   = deposit.status != "pending"
        completedView.isHidden = deposit.status != "complete"
        canceledView.isHidden  = deposit.status != "canceled"
        expiredView.isHidden   = deposit.status != "expired"
        
        let amount =  deposit.status == "complete" ? deposit.amountReceived : deposit.amountRequested
        walletAliasLabel.text = amount + " IPSX"
    }
}

extension TokenDepositsListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if deposits?.count ?? 0 > indexPath.row {
            selectedDeposit = deposits?[indexPath.row]
        }
        performSegue(withIdentifier: "showSummarySegueID", sender: self)
    }
}

extension TokenDepositsListController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView) {
            
            // Calculate new header height
            var newHeight = self.headerHeightConstraint.constant
            if isScrollingDown {
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp {
                newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
            }
            
            // Header needs to animate
            if newHeight != self.headerHeightConstraint.constant {
                self.headerHeightConstraint.constant = newHeight
                self.updateHeader()
                self.setScrollPosition(self.previousScrollOffset)
            }
            
            self.previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
}

extension TokenDepositsListController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.addSubview(toastView)
        }
    }
}

extension TokenDepositsListController: ErrorPresentable {
    
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
            case IPRequestType.userInfo, IPRequestType.getEthAddress:
                self.errorMessage = "Refresh Data Error Message".localized
            case IPRequestType.deleteEthAddress:
                self.errorMessage = "ETH Address Delete Failed Error Message".localized
            default:
                self.errorMessage = "Generic Error Message".localized
            }
        }
    }
}

