//
//  TokenRequestListController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class TokenRequestListController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var noItemsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var toastHolderView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var tokenRequests: [TokenRequest] = []
    
    private var timer: Timer?
    private let refreshInterval: TimeInterval = 30
    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(self.pulltoRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        getTokenRequestList()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        timer?.invalidate()
    }
    
    @objc func pulltoRefresh() {
        timer?.invalidate()
        getTokenRequestList(tableviewPull: true)
    }

    @objc func updateData() {
        getTokenRequestList()
    }

    @IBAction func createRequestAction(_ sender: Any) {
        
        guard UserManager.shared.hasValidAddress else {
            toast?.showToastAlert("Need one validated ETH address message.".localized, autoHideAfter: 5)
            return
        }
        
        let maxTokenRequests = UserManager.shared.generalSettings?.maxTokenRequests ?? 5
        var noOfTokenRequests: Int = 1
        
        if let tokenRequests = UserManager.shared.tokenRequests {
            for tokenRequest in tokenRequests {
                if tokenRequest.isFromToday() {
                    noOfTokenRequests = noOfTokenRequests + 1
                }
            }
        }
        if noOfTokenRequests <= maxTokenRequests {
            self.performSegue(withIdentifier: "showCreateTokenSegueID", sender: self)
        } else {
            let formatedMessage = String(format: "Max %@ Token Requests Error Message".localized, "\(maxTokenRequests)")
            self.errorMessage = formatedMessage
        }
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

    func updateUI() {
        
        DispatchQueue.main.async {
            self.tokenRequests = UserManager.shared.tokenRequests ?? []
            self.tokenRequests.sort { $0.created ?? Date() > $1.created ?? Date() } 
            self.separatorView.isHidden = self.tokenRequests.count < 1
            self.noItemsLabel.isHidden = self.tokenRequests.count > 0
            self.tableView.reloadData()
        }
    }
    
    func getTokenRequestList(tableviewPull: Bool = false) {
        
        if !tableviewPull { self.loadingView?.startAnimating() }
        
        TokenDepositService().getTokenRequestList() { result in
            
            DispatchQueue.main.async {
                self.loadingView?.stopAnimating()
                self.refreshControl.endRefreshing()
                
                if tableviewPull {
                    self.timer = Timer.scheduledTimer(timeInterval: self.refreshInterval, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
                }
                
                switch result {
                case .success(let tokenRequests):
                    UserManager.shared.tokenRequests = tokenRequests as? [TokenRequest]
                    self.updateUI()
                    
                case .failure(let error):
                    self.handleError(error, requestType: .getTokenRequestList, completion: {
                        self.getTokenRequestList()
                    })
                }
            }
        }
    }
    
    private func ethAddressFor(tokenRequest: TokenRequest) -> EthAddress? {
        var ethAddress: EthAddress? = nil
        if let addresses = UserManager.shared.ethAddresses {
            let matches = addresses.filter { return $0.ethID == tokenRequest.ethID }
            if matches.count == 1 {
                ethAddress = matches.first
            }
        }
        return ethAddress
    }
    
}

extension TokenRequestListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokenRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TokenRequestCell.cellID, for: indexPath) as! TokenRequestCell
        let tokenRequest = tokenRequests[indexPath.item]
        let address      = ethAddressFor(tokenRequest: tokenRequest)
        cell.configure(tokenRequest: tokenRequest, ethAdrress: address)
        return cell
    }
}

class TokenRequestCell: UITableViewCell {
    
    static let cellID = "TokenRequestCellID"

    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    @IBOutlet weak var canceledView: RoundedView!
    
    func configure(tokenRequest: TokenRequest, ethAdrress: EthAddress? = nil) {
        if let date = tokenRequest.created {
            dateLabel.text = DateFormatter.dateStringForTokenRequests(date: date)
        }
        aliasLabel.text = ethAdrress?.alias ?? "My Address".localized
        quantityLabel.text = "Requested: " + tokenRequest.amount
        pendingView.isHidden   = tokenRequest.status != "pending"
        completedView.isHidden = tokenRequest.status != "completed"
        canceledView.isHidden  = tokenRequest.status != "rejected"
    }
}

extension TokenRequestListController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension TokenRequestListController: ErrorPresentable {
    
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
