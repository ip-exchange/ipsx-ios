//
//  MarketCheckoutController.swift
//  IPSX
//
//  Created by Calin Chitu on 22/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class MarketCheckoutController: UIViewController {

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var activationInfoAttributedLabel: UILabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var priceIPSXLabel: UILabel!
    @IBOutlet weak var priceUSDLabel: UILabel!
    
    @IBOutlet weak var orderCompleteOverlayView: UIView!
    @IBOutlet weak var orderCompleteOverlayYAxis: NSLayoutConstraint!
    @IBOutlet weak var orderCompleteNumberLabel: UILabel!

    @IBOutlet weak var topSeparatorConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint = topSeparatorConstraint
        }
    }

    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    var cart: Cart?
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    private let unwindToMarketSegueID = "UnwindToMarketSegueID"
    var ipAddress: String = "Getting IP info...".localized
    var orderIdString: String = "Order #"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        getIPAddress()
        updateOrderOverlay(visible: false)

        let attributedString = NSMutableAttributedString(string: "The proxies will be activated in \nmaximum 5 minutes after purchase!", attributes: [
            .font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            .foregroundColor: UIColor(white: 153.0 / 255.0, alpha: 1.0)
            ])
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14.0, weight: .bold), range: NSRange(location: 34, length: 17))
        activationInfoAttributedLabel.attributedText = attributedString
    }
    
    func configureUI() {
        
        ipLabel.text = ipAddress
        priceIPSXLabel.text = cart?.ipsxTotal.cleanString
        priceUSDLabel.text  = "(\(cart?.usdTotal.cleanString ?? "-") $)"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }

    @IBAction func rentAction(_ sender: Any) {
        performOrderRequest(ipAddress: ipAddress)
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func getIPAddress() {
        
        loadingView?.startAnimating()
        IPService().getPublicIPAddress(completion: { error, ipAddress in
            
            self.loadingView?.stopAnimating()
            guard let ipAddress = ipAddress, error == nil else {
                self.errorMessage = "Generic Error Message".localized
                return
            }
            self.ipAddress = ipAddress
            DispatchQueue.main.async { self.configureUI() }
        })
    }
    
    func performOrderRequest(ipAddress: String) {
        
        loadingView?.startAnimating()
        MarketplaceService().placeOrder(ipAddress: ipAddress, completionHandler: { result in

            self.loadingView?.stopAnimating()
            switch result {
            case .success(let orderId):
                self.orderIdString += (orderId as? String) ?? ""
                DispatchQueue.main.async {
                    self.updateOrderOverlay(visible: true)
                }

            case .failure(let error):
                self.handleError(error, requestType: RequestType.placeOrder, completion: {
                    self.performOrderRequest(ipAddress: ipAddress)
                })
            }
        })
    }
    
    private func updateOrderOverlay(visible: Bool) {
        view.layoutIfNeeded()
        self.orderCompleteOverlayYAxis.constant = visible ? 0 : 500
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
            self.orderCompleteNumberLabel.text = self.orderIdString
            self.orderCompleteOverlayView.alpha = visible ? 1 : 0
        })
    }
    
}

extension MarketCheckoutController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension MarketCheckoutController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
            
        case CustomError.ipNotSupported:
            self.errorMessage = "IP Not Supported Error Message".localized
            
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}
