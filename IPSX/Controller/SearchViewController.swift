//
//  SearchViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    let cellID = "SearchCellID"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    public var dismissOnSelect = false
    
    //TODO (CC): get this from API
    var countries: [String] = []
    var filteredCountries: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.isHidden = navigationController != nil
        backButton.isHidden  = !closeButton.isHidden
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
        
       //TODO (CC): Delete this when API get list is implemented
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
        filteredCountries = countries
        tableView.reloadData()
    }
    
    @IBAction func BackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func CloseButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard let keyboardFrame = notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        bottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SearchCell
        cell.textlabel.text = filteredCountries[indexPath.item]
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected:", filteredCountries[indexPath.item])
        //TODO: Do something with the selected country
       if dismissOnSelect {
             if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
        } else {
            //TODO: Perform a segue to the next screen
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        guard newString.count > 0 else {
            filteredCountries = countries
            tableView.reloadData()
            tableView.setContentOffset(CGPoint.zero, animated: true)
            return true
        }
        let matchingTerms = countries.filter({
            $0.range(of: newString, options: .caseInsensitive) != nil
        })
        filteredCountries = matchingTerms
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.zero, animated: true)

        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        filteredCountries = countries
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.zero, animated: true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.returnKeyType = .done
        return true
    }
    
}

class SearchCell: UITableViewCell {
    @IBOutlet weak var textlabel: UILabel!
 }