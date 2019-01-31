//
//  WithdrawSubmitController.swift
//  IPSX
//
//  Created by Calin Chitu on 10/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class WithdrawSubmitController: UIViewController {
    
    
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var priceIPSXLabel: UILabel!
    @IBOutlet weak var priceUSDLabel: UILabel!    
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
    
    var errorMessage: String? {
        didSet {
            if ReachabilityManager.shared.isReachable() {
                toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
            }
        }
    }
    
    var selectedAddress: EthAddress?
    var selectedAmount: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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
    }
    
    @IBAction func submitAction(_ sender: Any) {
        createWithdrawal()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    private func createWithdrawal() {
        
        guard let addrString = selectedAddress?.address, selectedAmount > 0 else {
            toast?.showToastAlert("Missing address or insuficient amount".localized, autoHideAfter: 5, type: .error, dismissable: true)
            return
        }
        
        loadingView.startAnimating()
        FundsService().createWithdrawal(ethAddrString: addrString, amount: selectedAmount) { result in
            DispatchQueue.main.async { self.loadingView.stopAnimating() }
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    DispatchQueue.main.async { self.performSegue(withIdentifier: "UnwindToWithdrawsList", sender: self) }
                }
                
            case .failure(let error):
                self.handleError(error, requestType: RequestType.createWithdraw, completion: {
                    self.createWithdrawal()
                })
            }
        }
    }

    private func updateUI() {
        walletNameLabel.text = selectedAddress?.alias
        walletAddressLabel.text = selectedAddress?.address
        priceIPSXLabel.text = "\(selectedAmount)"
        //TODO: Use an api to get the actual rate for user selected amount in IPSX
        priceUSDLabel.text = "(\(selectedAmount / 100) $)"
    }
}

extension WithdrawSubmitController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension WithdrawSubmitController: ErrorPresentable {
    
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
            default:
                self.errorMessage = "Generic Error Message".localized
            }
        }
    }
}
