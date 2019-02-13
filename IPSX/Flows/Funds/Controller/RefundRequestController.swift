//
//  RefundRequestController.swift
//  IPSX
//
//  Created by Calin Chitu on 18/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class RefundRequestController: UIViewController {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var refundTitleLabel: UILabel!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var proxyTitle: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    @IBOutlet weak var refundPlaceholder: UILabel!
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }

    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var onRefundSuccess:(()->())?
    
    var proxy: Proxy?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reasonTextView.resignFirstResponder()
    }
    
    @IBAction func requestRefundAction(_ sender: Any) {
        
        guard reasonTextView.text.count >= 10, reasonTextView.text.count <= 1000 else {
            let toastText = "The reason must be at least 10 characters, maximum 1000.".localized
            toast?.showToastAlert(toastText, autoHideAfter: 5, type: .error, dismissable: true)
            return
        }
        
        submitRefund()
    }
    
    @IBAction func closeAction(_ sender: Any) {
         dismiss(animated: true)
    }
    
    private func submitRefund() {
        
        if let proxyId = proxy?.pacId {
            let proxyIdString = String(proxyId)
            let reason = reasonTextView.text ?? ""
            
            loadingView.startAnimating()
            FundsService().createRefund(proxyId: proxyIdString, reason: reason) { result in
                DispatchQueue.main.async { self.loadingView.stopAnimating() }
                switch result {
                case .success(_):
                    self.proxy?.hasRequestedRefund = true
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            self.onRefundSuccess?()
                        }
                    }
                    
                case .failure(let error):
                    self.handleError(error, requestType: RequestType.createRefund, completion: {
                        self.submitRefund()
                    })
                }
            }
        }
    }
    
    private func updateUI() {
        
        guard let validProxy = proxy else { return }
        
        reasonTextView.becomeFirstResponder()
        reasonTextView.text = ""
        proxyTitle.text = "Refund for Proxy #\(String(describing: validProxy.pacId))".localized
    }

}

extension RefundRequestController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        refundPlaceholder.isHidden = textView.text.count > 0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        refundPlaceholder.isHidden = textView.text.count > 0
    }
}

extension RefundRequestController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}


extension RefundRequestController: ErrorPresentable {
    
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
