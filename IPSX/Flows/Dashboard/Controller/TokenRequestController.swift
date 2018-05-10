//
//  TokenRequestController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class TokenRequestController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    
    var errorMessage: String? {
        didSet {
            //toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        
        //TODO (CVI): this is for testing
        let ethID = UserManager.shared.userInfo?.ethAddresses?.first?.ethID ?? ""
        let amount = amountTextField.text ?? "0"
        
        ProxyService().requestTokens(ethID: ethID, amount: amount, completionHandler: { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(_):
                self.errorMessage = ""
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
