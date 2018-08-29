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
    
    var company: Company?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyRTextField.contentTextField?.text = company?.representative.name
        emailRtextField.contentTextField?.text = company?.representative.email
        phoneRTextField.contentTextField?.text = company?.representative.phone
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
        company?.representative.name  = companyRTextField.contentTextField?.text ?? ""
        company?.representative.email = emailRtextField.contentTextField?.text ?? ""
        company?.representative.phone = phoneRTextField.contentTextField?.text ?? ""
    }
}
