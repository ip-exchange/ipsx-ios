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
    
    var legalDetails: LegalDetailsObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyRTextField.contentTextField?.text = legalDetails?.repName
        emailRtextField.contentTextField?.text = legalDetails?.repEmail
        phoneRTextField.contentTextField?.text = legalDetails?.repPhone
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        collectData()
        
        print(legalDetails?.companyName ?? "")
        print(legalDetails?.companyVat ?? "")
        print(legalDetails?.companyAddress ?? "")
        print(legalDetails?.companyCountry ?? "")
        print(legalDetails?.companyRegNumber ?? "")
        print(legalDetails?.repName ?? "")
        print(legalDetails?.repPhone ?? "")
        print(legalDetails?.repEmail ?? "")
        
        //TODO (CVI-LegalStuff): Use all that data and make the request before dismiss
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        collectData()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func collectData() {
        legalDetails?.repName  = companyRTextField.contentTextField?.text
        legalDetails?.repEmail = emailRtextField.contentTextField?.text
        legalDetails?.repPhone = phoneRTextField.contentTextField?.text
    }
}
