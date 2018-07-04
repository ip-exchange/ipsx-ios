//
//  TokenDepositsListController.swift
//  IPSX
//
//  Created by Calin Chitu on 04/07/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class TokenDepositsListController: UIViewController {

    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var hidableDownView: UIView!
    @IBOutlet weak var topRootView: UIView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var particlesHolder: UIView!
    
    let maxHeaderHeight: CGFloat = 215;
    let minHeaderHeight: CGFloat = 44;
    var previousScrollOffset: CGFloat = 0;
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    //TODO (CVI): Replace with deposits
    var tokenRequests: [TokenRequest] = []

    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    @IBAction func createDepositAction(_ sender: Any) {
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topRootView, text: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        //TODO (CVI): Replace with deposits
        getTokenRequestList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        particlesHolder.createParticlesAnimation()
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
    
    //TODO (CVI): Replace with deposits
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

    func updateUI() {
        
        DispatchQueue.main.async {
            self.tokenRequests = UserManager.shared.tokenRequests ?? []
            self.tableView.reloadData()
        }
    }

}


extension TokenDepositsListController: UITableViewDataSource {
    
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
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
            
        default:
            
            switch requestType {
            case .userInfo, .getEthAddress:
                self.errorMessage = "Refresh Data Error Message".localized
            case .deleteEthAddress:
                self.errorMessage = "ETH Address Delete Failed Error Message".localized
            default:
                self.errorMessage = "Generic Error Message".localized
            }
        }
    }
}

