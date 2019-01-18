//
//  RefundDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 17/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class RefundDetailsController: UIViewController {

    @IBOutlet weak var refundTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var adminResponseTextView: UITextView!
    @IBOutlet weak var issuedByLabel: UILabel!
    @IBOutlet weak var proxyNumber: UILabel!
   
    @IBOutlet weak var completedView: RoundedView!
    @IBOutlet weak var pendingView: RoundedView!
    @IBOutlet weak var canceledView: RoundedView!
    @IBOutlet weak var viewProxyButton: UIButton!
    
    //TODO(CC): add loadingView to this screen
    @IBOutlet weak var loadingView: CustomLoadingView!
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    var toast: ToastAlertView?
    var refund: Refund?
    var orderOfferProxyId: Int?
    var hideProxButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewProxyButton.isHidden = hideProxButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if refund == nil {
            getRefundDetails() { refund in
                DispatchQueue.main.async {
                    self.refund = refund 
                    self.updateUI()
                }
            }
        } else {
            updateUI()
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func updateUI() {
        
        guard let refund = refund else { return }
        
        let refundNb = refund.id
        refundTitleLabel.text = "Refund".localized + " #\(refundNb)"
        amountLabel.text = refund.value
        
        if let createdDate = refund.createdAt {
            dateLabel.text = DateFormatter.dateStringForTokenRequests(date: createdDate)
        }
        issuedByLabel.text = refund.issuedByUser ? "You".localized : "Admin".localized
        proxyNumber.text = "#\(refund.proxyId)"
        
        reasonTextView.text = refund.userReason.count > 0 ? refund.userReason : "No reason".localized
        adminResponseTextView.text = refund.adminReason.count > 0 ? refund.adminReason : "No reason".localized
        
        pendingView.isHidden   = refund.status != "pending"
        completedView.isHidden = refund.status != "completed"
        canceledView.isHidden  = refund.status != "rejected"
    }
    
    func getRefundDetails(completion:@escaping ((Refund?) -> ())) {
        
        guard let orderOfferProxyId = orderOfferProxyId else { return }
        loadingView?.startAnimating()
        
        FundsService().getRefundDetails(proxyId: orderOfferProxyId, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
            case .success(let refund):
                DispatchQueue.main.async {
                    completion(refund as? Refund)
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getOrderOfferProxy, completion: {
                    self.getRefundDetails(completion: completion)
                })
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewProxySegue" {
            let dest = segue.destination as? DashboardDetailsController
            dest?.shouldDismiss = true
            dest?.orderOfferProxyId = refund?.proxyId
            dest?.singleProxyView = true
        }
    }
}

extension RefundDetailsController: ErrorPresentable {
    
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
