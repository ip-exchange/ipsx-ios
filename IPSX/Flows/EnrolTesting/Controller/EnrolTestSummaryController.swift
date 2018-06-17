//
//  EnrolTestSummaryController.swift
//  IPSX
//
//  Created by Calin Chitu on 24/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EnrolTestSummaryController: UIViewController {
    
    
    @IBOutlet weak var ethAddresAlias: UILabel!
    @IBOutlet weak var ethAddress: UILabel!
    @IBOutlet weak var enroledDate: UILabel!
    @IBOutlet weak var enroledTime: UILabel!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    var enroledAddress: EthAddress?
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    var errorMessage: String? {
        didSet {
            self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateUI()
        enrollmentDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
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
    
    private func updateUI() {
        ethAddresAlias.text = enroledAddress?.alias
        ethAddress.text     = enroledAddress?.address
        enroledDate.text    = enroledAddress?.testingEnrollmentDate?.dateToString(format: "dd MMM yyyy") ?? "-- --- --"
        enroledTime.text    = enroledAddress?.testingEnrollmentDate?.dateToString(format: "HH:mm") ?? "--:--"
    }
    
    func enrollmentDetails() {
        
        loadingView?.startAnimating()
        EnrollmentService().getEnrollmentDetails(requestType: .enrollTestingDetails, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let details):
                if let details = details as? (String, Date) {
                    let createdDate = details.1
                    
                    DispatchQueue.main.async {
                        self.enroledDate.text = createdDate.dateToString(format: "dd MMM yyyy")
                        self.enroledTime.text = createdDate.dateToString(format: "HH:mm")
                    }
                }
                else {
                    self.errorMessage = "Generic Error Message".localized
                }

            case .failure(let error):
                self.handleError(error, requestType: .enrollTesting, completion: {
                    self.enrollmentDetails()
                })
            }
        })
    }
}

extension EnrolTestSummaryController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension EnrolTestSummaryController: ErrorPresentable {
    
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
