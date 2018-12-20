//
//  DashboardOrderController.swift
//  IPSX
//
//  Created by Calin Chitu on 04/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class DashboardOrderController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var headerTotalLabel: UILabel!
    @IBOutlet weak var headerVATLabel: UILabel!
    @IBOutlet weak var headerSubtotalLabel: UILabel!

    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var offersCounter: UILabel!
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var order: Order? = nil {
        didSet {
            offers = order?.offers ?? []
        }
    }
    
    var offers: [Offer] = [] {
        didSet {
            DispatchQueue.main.async { self.tableView?.reloadData() }
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
    
    fileprivate let cellID = "DashboardCellID"
    fileprivate let itemDetailsSegueID = "ItemDetailsSegueID"
    
    private var timer: Timer?
    
    var selectedOffer: Offer?
    var shouldRefreshIp = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    private func updateUI() {
        titleLabel.text = "Order".localized + " #\(order?.id ?? 0)"
        let tailString = offers.count == 1 ? "offer".localized : "offers".localized
        offersCounter.text = "\(offers.count) " + tailString
        
        headerSubtotalLabel.text = "\(order?.summary?.ipsxSubtotal.cleanString ?? "0")"
        headerVATLabel.text      = "\(order?.summary?.ipsxVat.cleanString ?? "0")"
        headerTotalLabel.text    = "\(order?.summary?.ipsxTotal.cleanString ?? "0")"
        
        if let createdDate = order?.created {
            
            let dateFormatter = DateFormatter()
            let dateFormat = "dd MMM yyyy"
            let hourFormat = "HH:mm"
            dateFormatter.dateFormat = dateFormat
            startDateLabel.text = dateFormatter.string(from: createdDate)
            dateFormatter.dateFormat = hourFormat
            startHourLabel.text = dateFormatter.string(from: createdDate)
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
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == itemDetailsSegueID {
            let detailsController = segue.destination as? DashboardDetailsController
            detailsController?.offer = selectedOffer
        }
    }

}


extension DashboardOrderController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DashboardCell
        cell.configure(offer: offers[indexPath.row], state: .active)
        return cell
    }
}

extension DashboardOrderController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOffer = offers[indexPath.row]
        DispatchQueue.main.async { self.performSegue(withIdentifier: self.itemDetailsSegueID, sender: self) }
    }
}

extension DashboardOrderController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension DashboardOrderController: ErrorPresentable {
    
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
