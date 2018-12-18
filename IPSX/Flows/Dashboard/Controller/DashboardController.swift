//
//  DashboardController.swift
//  IPSX
//
//  Created by Calin Chitu on 03/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class DashboardController: UIViewController, UITabBarControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var customTabBar: CustomTabBar!

    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var orders: [Order] = [] {
        didSet {
            DispatchQueue.main.async { self.tableView.reloadData() }
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
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    
    var shouldShowOrderHint = false
    
    fileprivate let cellID = "DashboardCellID"
    fileprivate let detailsSegueID = "DetailsSegueID"
    fileprivate let viewOrderSegueID = "ViewOrderSegueID"
    fileprivate let historySegueID = "HistorySegueID"
    
    private var timer: Timer?
    var selectedOffer: Offer?
    var selectedOrder: Order?
    var shouldRefreshIp = true
    private var tutorialPresented = false
    private var showOrderComplete = false
    
    private var backFromSegue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noDataView.isHidden = true
        customTabBar.selectIndex(0)
        customTabBar.onTap = { index in
            self.tabBarController?.selectedIndex = index
        }
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.tabBarController?.delegate = self
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
        
        tabBarController?.tabBar.isHidden = true
        guard UserManager.shared.isLoggedIn else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        
        if !backFromSegue { self.updateData() }
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
        
        loadDataIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if backFromSegue { self.updateData() }
        backFromSegue = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        self.timer?.invalidate()
    }
    
    func loadDataIfNeeded() {
        
        if UserManager.shared.allCountries == nil {
            
            UserInfoService().getCountryList(completionHandler: { result in
                
                switch result {
                case .success(let countryList):
                    UserManager.shared.allCountries = countryList as? [[String: String]]
                    
                case .failure(_): break
                }
            })
        }
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
    
    @objc func updateData() {
        loadOrders()
    }
    
    func loadOrders() {
        
        loadingView?.startAnimating()
        MarketplaceService().getOrders(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let orders):
                DispatchQueue.main.async {
                    self.orders = orders as? [Order] ?? []
                    self.noDataView.isHidden = self.orders.count > 0
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getOrders, completion: {
                    self.loadOrders()
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        backFromSegue = true
        segue.destination.hidesBottomBarWhenPushed = true
        if segue.identifier == detailsSegueID {
            let detailsController = segue.destination as? DashboardDetailsController
            detailsController?.offer = selectedOffer
        }
        if segue.identifier == viewOrderSegueID {
            let detailsController = segue.destination as? DashboardOrderController
            detailsController?.order = selectedOrder
        }
        if segue.identifier == historySegueID {
            let nav = segue.destination as? UINavigationController
            let detailsController = nav?.viewControllers.first as? DashboardHistoryController
            detailsController?.orders = self.orders
        }
    }
    
    @IBAction func unwindToDashboard(segue:UIStoryboardSegue) {
        if let _ = segue.source as? MarketCheckoutController {
            shouldShowOrderHint = true
        }
    }

}


extension DashboardController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders[section].offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DashboardCell
        cell.configure(offer: orders[indexPath.section].offers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 50
        if section == 0, shouldShowOrderHint {
            height += 79
        } else if section > 0 {
            height -= 12
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCellID") as? DashboardHeaderCell
        if section > 0 {
            cell?.labelesTopConstraint?.constant -= 12
        }
        let orderNumber = "Order".localized + " #\(orders[section].id)"
        cell?.updateCell(sectionIndex: section, orderNumber: orderNumber)
        cell?.onTap = { section in
            self.selectedOrder = self.orders[section]
            DispatchQueue.main.async { self.performSegue(withIdentifier: self.viewOrderSegueID, sender: self) }
        }
        return cell
    }
}

extension DashboardController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { shouldShowOrderHint = false }
        selectedOffer = orders[indexPath.section].offers[indexPath.row]
        DispatchQueue.main.async { self.performSegue(withIdentifier: self.detailsSegueID, sender: self) }
    }
}

extension DashboardController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension DashboardController: ErrorPresentable {
    
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
