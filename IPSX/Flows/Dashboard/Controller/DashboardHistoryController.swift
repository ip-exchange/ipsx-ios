//
//  DashboardHistoryController.swift
//  IPSX
//
//  Created by Calin Chitu on 04/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class DashboardHistoryController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var orders: [Order] = [] {
        didSet {
            DispatchQueue.main.async { self.tableView?.reloadData() }
        }
    }
    var ordersDatasource: [Order] {
        return orders.filter { $0.validForDashboard == false }
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
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    
    fileprivate let cellID = "DashboardCellID"
    fileprivate let detailsSegueID = "DetailsSegueID"
    
    private let orderSegueID = "OrderSegueID"
    private var daysTobeConsideredOlder: Int = 7
    
    var selectedOffer: Offer?
    var selectedOrder: Order?
    var shouldRefreshIp = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    func updateReachabilityInfo() {
        
        if !ReachabilityManager.shared.isReachable() {
            self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
        } else if self.toast?.currentText == "No internet connection".localized {
            self.toast?.hideToastAlert()
        }
        
        guard shouldRefreshIp else { return }
        DispatchQueue.main.async {
            self.shouldRefreshIp = false
            switch ReachabilityManager.shared.connectionType {
            case .wifi, .cellular:
                IPService().getPublicIPAddress() { error, ipAddress in
                    DispatchQueue.main.async {
                        if ipAddress == nil {
                            self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
                        }
                    }
                }
            case .none:
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            }
        }
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            self.shouldRefreshIp = true
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else {
                self.toast?.hideToastAlert()
            }
            self.updateReachabilityInfo()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailsSegueID {
            let detailsController = segue.destination as? DashboardDetailsController
            detailsController?.offer = selectedOffer
        }
        if segue.identifier == orderSegueID {
            let detailsController = segue.destination as? DashboardOrderController
            detailsController?.order = selectedOrder
        }
    }
    
}


extension DashboardHistoryController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ordersDatasource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersDatasource[section].offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DashboardCell
        cell.configure(offer: ordersDatasource[indexPath.section].offers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let order = ordersDatasource[section]
        let prevOrder = section > 0 ? ordersDatasource[section - 1] : ordersDatasource[section]
        
        let diffInDays = Calendar.current.dateComponents([.day], from: order.created, to: Date()).day ?? 0
        let diffInDaysPrev = Calendar.current.dateComponents([.day], from: prevOrder.created, to: Date()).day ?? 0
        
        switch (section, diffInDays, diffInDaysPrev) {
        case (0, 0...daysTobeConsideredOlder, _):
            return 78
        case (0, daysTobeConsideredOlder + 1...Int.max, _):
            return 78
        case (1...Int.max, daysTobeConsideredOlder + 1...Int.max, daysTobeConsideredOlder):
            return 78
        default:
            return 38
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCellID") as? DashboardHeaderCell
        cell?.onTap = { [weak self] section in
            guard let weakSelf = self else { return }
            weakSelf.selectedOrder = weakSelf.ordersDatasource[section]
            DispatchQueue.main.async { weakSelf.performSegue(withIdentifier: weakSelf.orderSegueID, sender: weakSelf) }
        }
        
        let order = ordersDatasource[section]
        let prevOrder = section > 0 ? ordersDatasource[section - 1] : ordersDatasource[section]
        let orderTitle =  "Order".localized + " #\(order.id)"
        
        let diffInDays = Calendar.current.dateComponents([.day], from: order.created, to: Date()).day ?? 0
        let diffInDaysPrev = Calendar.current.dateComponents([.day], from: prevOrder.created, to: Date()).day ?? 0

        switch (section, diffInDays, diffInDaysPrev) {
        case (0, 0...daysTobeConsideredOlder, _):
            cell?.updateCell(sectionIndex: section, historyTitle: "Last Week".localized, orderNumber: orderTitle)
        case (0, daysTobeConsideredOlder + 1...Int.max, _):
            cell?.updateCell(sectionIndex: section, historyTitle: "Older Than \(daysTobeConsideredOlder) Days".localized, orderNumber: orderTitle)
        case (1...Int.max, daysTobeConsideredOlder + 1...Int.max, daysTobeConsideredOlder):
            cell?.updateCell(sectionIndex: section, historyTitle: "Older".localized, orderNumber: orderTitle)
        default:
            cell?.updateCell(sectionIndex: section, orderNumber: orderTitle)
        }
        
        return cell
    }
}

extension DashboardHistoryController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOffer = ordersDatasource[indexPath.section].offers[indexPath.row]
        DispatchQueue.main.async { self.performSegue(withIdentifier: self.detailsSegueID, sender: self) }
    }
}

extension DashboardHistoryController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

