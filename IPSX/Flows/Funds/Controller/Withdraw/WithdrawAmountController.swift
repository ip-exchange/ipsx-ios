//
//  WithdrawAmountController.swift
//  IPSX
//
//  Created by Calin Chitu on 10/12/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class WithdrawAmountController: UIViewController {
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountView: RichTextFieldView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var nextButton: RoundedButton!
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
    private var fieldsStateDic: [String : Bool] = ["amount" : false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        observreFieldsState()
        amountView.updateColors(isValid: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.amountTextField.becomeFirstResponder()
     }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTextViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.amountTextField.resignFirstResponder()
    }
    
    @IBAction func nextStepAction(_ sender: Any) {
        DispatchQueue.main.async { self.performSegue(withIdentifier: "SubmitWithdrawSegueID", sender: self) }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTextViews() {
        amountView.validationRegex = RichTextFieldView.minOneCharRegex
    }
    
    private func observreFieldsState() {
        amountView.onFieldStateChange = { state in
            self.fieldsStateDic["amount"] = state
            self.nextButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SubmitWithdrawSegueID" {
            
            if let amount = amountTextField.text {
                
                self.fieldsStateDic["amount"] = true
                let dest = segue.destination as? WithdrawSubmitController
                dest?.selectedAddress = selectedAddress
                dest?.selectedAmount = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0
            }
        }
    }
    
}

extension WithdrawAmountController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension WithdrawAmountController: ErrorPresentable {
    
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
