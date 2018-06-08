//
//  EnrolStakeSummaryController.swift
//  IPSX
//
//  Created by Calin Chitu on 28/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EnrolStakeSummaryController: UIViewController {

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
    
    var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    // [(ethId, createdDate)]
    var enrollment: [(ethID: String, createdDate: Date)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editButton.isHidden = enroledAddresses == nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        enrollmentDetails()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editStakingsSegueID" {
            let enrolController = segue.destination as? EnrolStakeSubscribeController
            enrolController?.editMode = true
            enrolController?.enroledAddresses = self.enroledAddresses
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
                    if let details = details as? [(ethID: String, createdDate: Date)], let firstEnroled = details.first {
                        self.enrollment = details
                        let ethToDisplay = UserManager.shared.ethAddres(forID: firstEnroled.ethID)
                        let letDateToDisplay = firstEnroled.createdDate
                        self.walletAlliasLabel.text  = ethToDisplay?.alias
                        self.walletAddressLabel.text = ethToDisplay?.address
                        self.enrolmentDateLabel.text = letDateToDisplay.dateToString(format: "dd MMM yyyy")
                        self.enrolmentTimeLabel.text = letDateToDisplay.dateToString(format: "HH:mm")
                        
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
