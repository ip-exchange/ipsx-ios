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
    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: toastHolderView, text: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        getTokenRequestList()
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
            } else {
                self.toast?.hideToastAlert()
            }
        }
    }
    
    func updateUI() {
        
        DispatchQueue.main.async {
            self.tokenRequests = UserManager.shared.tokenRequests ?? []
            self.separatorView.isHidden = self.tokenRequests.count < 1
            self.noItemsLabel.isHidden = self.tokenRequests.count > 0
            self.tableView.reloadData()
        }
    }
    
    func getTokenRequestList() {
        
        self.loadingView?.startAnimating()
        ProxyService().getTokenRequestList(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let tokenRequests):
                UserManager.shared.tokenRequests = tokenRequests as? [TokenRequest]
                self.updateUI()
                 
            case .failure(let error):
                self.handleError(error, requestType: .getTokenRequestList, completion: {
                    self.getTokenRequestList()
                })
            }
        })
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
