//
//  RefundListController.swift
//  IPSX
//
//  Created by Calin Chitu on 05/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class RefundListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension RefundListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RefundCell.cellID, for: indexPath) as! RefundCell
        cell.configure()
        return cell
    }
}

extension RefundListController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}


extension RefundListController: ErrorPresentable {
    
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


class RefundCell: UITableViewCell {
    
    static let cellID = "RefundCellID"
    
    @IBOutlet weak var refundNbLabel: UILabel!
    @IBOutlet weak var refundIssuedBylabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    @IBOutlet weak var canceledView: RoundedView!
    @IBOutlet weak var expiredView: RoundedView!
    
    func configure() {
        dateLabel.text = DateFormatter.dateStringForTokenRequests(date: Date())
        quantityLabel.text = "100"
        pendingView.isHidden   = true
        completedView.isHidden = true
        canceledView.isHidden  = false
        expiredView.isHidden   = true
    }
}