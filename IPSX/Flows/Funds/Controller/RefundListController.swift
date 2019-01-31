//
//  RefundListController.swift
//  IPSX
//
//  Created by Calin Chitu on 05/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class RefundListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var contentSeparator: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    
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
    var refunds: [Refund] = []
    var selectedRefund: Refund?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentSeparator.isHidden = true
        noDataLabel.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRefunds()
    }
    
    private func getRefunds() {
        loadingView.startAnimating()
        FundsService().getRefundsList(completionHandler: { result in
            DispatchQueue.main.async { self.loadingView.stopAnimating() }
            switch result {
            case .success(let refunds):
                self.refunds = refunds as? [Refund] ?? []
                self.refunds = self.refunds.sorted() {
                    let d1 = $0.createdAt ?? Date()
                    let d2 = $1.createdAt ?? Date()
                    return d1.compare(d2) == .orderedDescending
                }
                DispatchQueue.main.async {
                    self.contentSeparator.isHidden = self.refunds.count < 1
                    self.noDataLabel.isHidden = self.refunds.count > 0
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.getRefundsList, completion: {
                    self.getRefunds()
                })
            }
        })
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RefundDetailsSegueID" {
            let dest = segue.destination as? RefundDetailsController
            dest?.refund = selectedRefund
            dest?.hideProxButton = false
        }
    }
}

extension RefundListController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return refunds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RefundCell.cellID, for: indexPath) as! RefundCell
        let refund = refunds[indexPath.item]
        cell.configure(refund: refund)
        return cell
    }
}

extension RefundListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRefund = refunds[indexPath.item]
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "RefundDetailsSegueID", sender: self)
        }
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
