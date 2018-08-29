//
//  CompanyDetailsController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/08/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class CompanyDetailsController: UIViewController {
    
    @IBOutlet weak var nameRTextField: RichTextFieldView!
    @IBOutlet weak var addressRTextField: RichTextFieldView!
    @IBOutlet weak var regNumberRTextField: RichTextFieldView!
    @IBOutlet weak var vatRTextField: RichTextFieldView!
    @IBOutlet weak var countryRTextField: RichTextFieldView!
    
    var company: Company?
    private var searchController: SearchViewController?
    private var representativeController: RepresentativeDetailsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if let representative = representativeController?.representative {
            company?.representative = representative
        }
        if UserManager.shared.userCountries == nil {
            
            UserInfoService().getUserCountryList(completionHandler: { result in
                
                switch result {
                case .success(let countryList):
                    UserManager.shared.userCountries = countryList as? [[String: String]]
                    DispatchQueue.main.async { self.updateFields() }
                    
                case .failure(_): break
                }
            })
        } else {
            self.updateFields()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "NextSegueID", let repController = segue.destination as? RepresentativeDetailsController {
            representativeController = repController
            collectData()
            repController.representative = company?.representative
        }
        
        if segue.identifier == "SearchSegueID", let srcController = segue.destination as? SearchViewController {
            srcController.dismissOnSelect = true
            srcController.countries = UserManager.shared.getUserCountryList()
            let userInfo = UserManager.shared.userInfo
            searchController = srcController
            searchController?.selectedCountry = UserManager.shared.getCountryName(countryID: userInfo?.countryID)
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func certificateUploadAction(_ sender: Any) {
    }
    
    private func collectData() {
        company?.name        = nameRTextField.contentTextField?.text ?? ""
        company?.address     = addressRTextField.contentTextField?.text ?? ""
        company?.registrationNumber = regNumberRTextField.contentTextField?.text ?? ""
        company?.vat         = vatRTextField.contentTextField?.text ?? ""
        company?.country     = countryRTextField.contentTextField?.text ?? ""
    }

    private func updateFields() {
        
        let userInfo = UserManager.shared.userInfo
        var countryName = UserManager.shared.getCountryName(countryID: userInfo?.countryID)
        
        if let selectedCountry = self.searchController?.selectedCountry {
            countryName = selectedCountry
        }
        self.countryRTextField.contentTextField?.text = countryName ?? "Select a country".localized
        
    }

}

