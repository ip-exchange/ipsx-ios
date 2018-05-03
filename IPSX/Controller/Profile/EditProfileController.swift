//
//  EditProfileController.swift
//  IPSX
//
//  Created by Calin Chitu on 02/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EditProfileController: UIViewController {

    @IBOutlet weak var keyIconImageView: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var telegramTextField: UITextField!
    
    @IBOutlet weak var selectedCountryLabel: UILabel!
    
    private var searchController: SearchViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyIconImageView.tintColor = .lightBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedCountryLabel.text = searchController?.selectedCountry ?? "Select a country"
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegueID", let srcController = segue.destination as? SearchViewController {
            srcController.dismissOnSelect = true
            searchController = srcController
        }
    }
}
