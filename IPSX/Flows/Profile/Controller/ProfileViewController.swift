//
//  ProfileViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 25/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var hidableDownView: UIView!
    @IBOutlet weak var topRootView: UIView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTopLabel: UILabel!
    @IBOutlet weak var enrolTestingTitleLabel: UILabel!
    @IBOutlet weak var enroledTestingImageView: UIImageView!
    @IBOutlet weak var enrolStakingTitleLabel: UILabel!
    @IBOutlet weak var enroledStakingImageView: UIImageView!
    @IBOutlet weak var userRoleLabel: UILabel!
    @IBOutlet weak var providerView: ProviderView!
    @IBOutlet weak var providerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var customTabBar: CustomTabBar!

    let maxHeaderHeight: CGFloat = 215;
    let minHeaderHeight: CGFloat = 44;
    var previousScrollOffset: CGFloat = 0;
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
  
    @IBAction func enrolTestingAction(_ sender: Any) {
        DispatchQueue.main.async {
            if UserManager.shared.isEnroledForTesting {
                self.performSegue(withIdentifier: "enrollTestingSummarySegueID", sender: self)
            } else if !UserManager.shared.hasValidAddress {
                self.toast?.showToastAlert("Need one validated ETH address message.".localized, autoHideAfter: 5)
            } else {
                self.performSegue(withIdentifier: "enrollTestingSegueID", sender: self)
            }
        }
    }
    
    @IBAction func EnrolStakingAction(_ sender: Any) {
        DispatchQueue.main.async {
            if UserManager.shared.isEnroledForStaking {
                self.performSegue(withIdentifier: "enrollStakingSummarySegueID", sender: self)
            } else if UserManager.shared.generalSettings?.stakingStatus == false {
                let endStakingDate = UserManager.shared.generalSettings?.stakingEndDate ?? "--:--:--"
                let stakingEndAlertText = String(format: "Staking Program end alert message %@".localized, "\(endStakingDate)")
                self.toast?.showToastAlert(stakingEndAlertText, autoHideAfter: 5, type: .info)
            } else if !UserManager.shared.hasValidAddress {
                self.toast?.showToastAlert("Need one validated ETH address message.".localized, autoHideAfter: 5)
            } else {
                self.performSegue(withIdentifier: "enrollStakingSegueID", sender: self)
            }
        }
    }
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }

    @IBAction func logoutButtonAction(_ sender: UIButton) {
        logout()
    }
    
    @IBAction func manageWalletsAction(_ sender: Any) {
        DispatchQueue.main.async { self.performSegue(withIdentifier: "WalletsListID", sender: nil) }
    }
        
    func logout() {
        
        UserManager.shared.logout()
        DispatchQueue.main.async { self.performSegue(withIdentifier: "showLandingSegueID", sender: nil) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        customTabBar.selectIndex(3)
        customTabBar.onTap = { index in
            self.tabBarController?.selectedIndex = index
        }
        configureUI()
        updateHeader()
        providerView.providerDelegate = self
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
        createToastAlert(onTopOf: topRootView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
        providerDetails()
        refreshProfileUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topRootView.createParticlesAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        topRootView.removeParticlesAnimation()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    func configureProviderView() {
        
        providerViewHeight.constant = 66
        let providerStatus = UserManager.shared.providerSubmissionStatus
        providerView.subbmissionStatus = providerStatus
    }
    
    func providerDetails() {
        
        ProviderService().getProviderStatus(completionHandler: { result in
            
            switch result {
            case .success(let status):
                UserManager.shared.providerSubmissionStatus = status as? ProviderStatus
                DispatchQueue.main.async {
                    self.configureProviderView()
                }
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.getProviderDetails, completion: {
                    self.providerDetails()
                })
            }
        })
    }
    

    func hideProviderView() {
        
        DispatchQueue.main.async {
            self.providerView.clipsToBounds = true
            self.providerViewHeight.constant = 0
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

    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeightConstraint.constant - self.minHeaderHeight
        let percentage = openAmount / range
        
        self.titleTopConstraint.constant = -openAmount + 10
        self.hidableDownView.alpha = percentage
    }

    private func configureUI() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.layer.borderColor  = UIColor.darkBlue.cgColor
        userImageView.layer.borderWidth  = 1
        self.headerHeightConstraint.constant = self.maxHeaderHeight
        tableView.tableFooterView = UIView()
    }
    
    func refreshProfileUI() {
        
        DispatchQueue.main.async {

            self.userRoleLabel.text = UserManager.shared.userRoleString
            if let username = self.userInfo?.userName {
                self.usernameLabel.text = username
                self.usernameTopLabel.text = username
            } else if let firstName = self.userInfo?.firstName {
                let lastName = self.userInfo?.lastName ?? ""
                self.usernameLabel.text    = firstName + " " + lastName
                self.usernameTopLabel.text = self.usernameLabel.text
            }
            self.enroledStakingImageView.isHidden = !UserManager.shared.isEnroledForStaking
            self.enroledTestingImageView.isHidden = !UserManager.shared.isEnroledForTesting
            self.enrolStakingTitleLabel.text = UserManager.shared.isEnroledForStaking ? "Enrolled for Staking Title".localized : "Enroll for Staking Title".localized
            self.enrolTestingTitleLabel.text = UserManager.shared.isEnroledForTesting ? "Enrolled for Testing Title".localized : "Enroll for Testing Title".localized
            if self.tableView.contentSize.height < self.view.frame.size.height {
                self.tableView.contentSize.height = self.view.frame.size.height
            }

        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        segue.destination.hidesBottomBarWhenPushed = true
        switch segue.identifier {
            
        case "showProfileSegueID":
            let navController = segue.destination as? UINavigationController
            let editProfileVC = navController?.viewControllers.first as? EditProfileController
            editProfileVC?.onDismiss = { hasUpdatedProfile in
                if hasUpdatedProfile {
                    self.retrieveUserInfo()
                }
            }
            
        case "enrollTestingSummarySegueID":
            let summaryController = segue.destination as? EnrolTestSummaryController
            summaryController?.enroledAddress = UserManager.shared.ethEnroledForTesting
            
        case "enrollStakingSummarySegueID":
            let navController = segue.destination as? UINavigationController
            let summaryController = navController?.viewControllers.first as? EnrolStakeSummaryController
            summaryController?.enroledAddresses = UserManager.shared.ethsEnroledForTesting

        default:
            break
        }
    }
    
    func retrieveUserInfo() {
        
        loadingView?.startAnimating()
        UserInfoService().retrieveUserInfo(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let user):
                UserManager.shared.userInfo = user as? UserInfo
                self.refreshProfileUI()
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.userInfo, completion: {
                    self.retrieveUserInfo()
                })
            }
        })
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

}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let isScrollingDown =  scrollView.contentOffset.y > 0
        let isScrollingUp = scrollView.contentOffset.y < 0
        
        var newHeight = self.headerHeightConstraint.constant
        if isScrollingDown {
            newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
        }
        
        if newHeight != self.headerHeightConstraint.constant {
            self.headerHeightConstraint.constant = newHeight
            self.updateHeader()
            self.setScrollPosition(self.previousScrollOffset)
        }
        
        self.previousScrollOffset = scrollView.contentOffset.y
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

extension ProfileViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.addSubview(toastView)
        }
    }
}

extension ProfileViewController: ErrorPresentable {
    
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

extension ProfileViewController: ProviderDelegate {
    
    func openProviderDetails(hasSubmittedProviderRequest: Bool) {
        
        DispatchQueue.main.async {
            if hasSubmittedProviderRequest {
                self.performSegue(withIdentifier: "showAboutProviderSegue", sender: nil)
            }
            else {
                self.performSegue(withIdentifier: "showBecomeProviderSegue", sender: nil)
            }
        }
    }
}
