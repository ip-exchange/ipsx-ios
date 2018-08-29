//
//  RepresentativeDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class RepresentativeDetailsController: UIViewController {

    @IBOutlet weak var companyRTextField: RichTextFieldView!
    @IBOutlet weak var emailRtextField: RichTextFieldView!
    @IBOutlet weak var phoneRTextField: RichTextFieldView!
    
    var representative: Representative?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyRTextField.contentTextField?.text = representative?.name
        emailRtextField.contentTextField?.text = representative?.email
        phoneRTextField.contentTextField?.text = representative?.phone
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        collectData()
        
        //TODO (CVI-LegalStuff): Use all that data and make the request before dismiss
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        collectData()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func collectData() {
        representative?.name  = companyRTextField.contentTextField?.text ?? ""
        representative?.email = emailRtextField.contentTextField?.text ?? ""
        representative?.phone = phoneRTextField.contentTextField?.text ?? ""
    }
}
