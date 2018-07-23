//
//  EnrolStakeSummaryController.swift
//  IPSX
//
//  Created by Calin Chitu on 28/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EnrolStakeSummaryController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var walletAlliasLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var enrolmentDateLabel: UILabel!
    @IBOutlet weak var enrolmentTimeLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var enroledAddresses: [EthAddress]? = nil
    var ethAdresses: [EthAddress] = []
    
    let cellHeight: Int = 58
    
    var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    // [(ethId, createdDate)]
    var enrollment: [(ethID: Int, createdDate: Date)] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        editButton.isHidden = enroledAddresses == nil
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
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
        enrollmentDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserManager.shared.generalSettings?.stakingStatus == false, let endStakingDate = UserManager.shared.generalSettings?.stakingEndDate {
            editButton.isHidden = true
            let stakingEndAlertText = String(format: "Staking Program end alert message %@".localized, "\(endStakingDate)")
            toast?.showToastAlert(stakingEndAlertText, type: .info, dismissable: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editStakingsSegueID" {
            let enrolController = segue.destination as? EnrolStakeSubscribeController
            enrolController?.editMode = true
            enrolController?.onDismiss = { hasUpdatedStaking in
                if hasUpdatedStaking {
                    self.enrollmentDetails()
                }
            }
        } else if segue.identifier == "WebViewSegueID" {
            let destinationWebController = segue.destination as? SimpleWebView
            destinationWebController?.loadingURLString = Url.faqPageUrl
            destinationWebController?.titleString = "FAQ".localized
        }
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

    func updateReachabilityInfo() {
        DispatchQueue.main.async {
            if ReachabilityManager.shared.isReachable() {
                self.toast?.hideToastAlert()
            } else {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            }
        }
    }

    func enrollmentDetails() {
        
        loadingView?.startAnimating()
        self.enrolmentDateLabel.text = "-- --- --"
        self.enrolmentTimeLabel.text = "--:--"
        self.walletAlliasLabel.text  = "Loading message".localized
        self.walletAddressLabel.text = "..."
        EnrollmentService().getEnrollmentDetails(requestType: .enrollStakingDetails, completionHandler: { result in
            DispatchQueue.main.async {
                self.loadingView?.stopAnimating()
                switch result {
                case .success(let details):
                    if let details = details as? [(ethID: Int, createdDate: Date)], let firstEnroled = details.min(by: { $0.createdDate < $1.createdDate }) {
                        self.enrollment = details
                        let ethToDisplay = UserManager.shared.ethAddres(forID: firstEnroled.ethID)
                        let letDateToDisplay = firstEnroled.createdDate
                        self.walletAlliasLabel.text  = ethToDisplay?.alias
                        self.walletAddressLabel.text = ethToDisplay?.address
                        self.enrolmentDateLabel.text = letDateToDisplay.dateToString(format: "dd MMM yyyy")
                        self.enrolmentTimeLabel.text = letDateToDisplay.dateToString(format: "HH:mm")
                        self.ethAdresses = []
                        for detail in details {
                            if let ethAddr = UserManager.shared.ethAddres(forID: detail.ethID), ethAddr.validationState == .verified {
                                self.ethAdresses.append(ethAddr)
                            }
                        }
                        self.tableViewHeightConstraint.constant = CGFloat(self.cellHeight * details.count)
                        self.view.layoutIfNeeded()
                        self.tableView.reloadData()
                        
                    }
                    else {
                        self.errorMessage = "Generic Error Message".localized
                    }
                    
                case .failure(let error):
                    self.handleError(error, requestType: .enrollTesting, completion: {
                        self.enrollmentDetails()
                    })
                }
            }
        })
    }
    
}

extension EnrolStakeSummaryController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ethAdresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EthWalletCell.cellID, for: indexPath) as! EthWalletCell
        let ethAddress = ethAdresses[indexPath.item]
        cell.configure(address: ethAddress, forceSelect: true)
        return cell
    }
}

extension EnrolStakeSummaryController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension EnrolStakeSummaryController: ErrorPresentable {
    
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
