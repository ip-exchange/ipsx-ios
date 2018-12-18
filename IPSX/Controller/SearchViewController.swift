//
//  SearchViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var selectedItemsCollectionview: UICollectionView!
    @IBOutlet weak var collectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }

    fileprivate let cellID = "SearchCellID"
    fileprivate let newProxyFlowID = "NewProxyFlowSegueID"
    fileprivate let reuseIdentifier = "CountryCellID"

    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var errorMessage: String? {
        didSet { self.toast?.showToastAlert(self.errorMessage) }
    }

    var multipleSelections = false
    var dismissOnSelect = false
    var dismissPresentingNav = false
    var isProxyFlow: Bool? = false
    var countries: [String]?
    var filteredCountries: [String]?
    var selectedCountries:[String] = []

    var selectedCountry: String?
    
    var onCountrySelected: ((_ selectedCountry: String)->())?
    var onSaveSelected: ((_ selectedCountres: [String])->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.isHidden = (isProxyFlow == false)
        backButton.isHidden  = !closeButton.isHidden
        saveButton.isHidden  = !multipleSelections
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        filteredCountries = isProxyFlow == true ? [] : countries
        tableView.reloadData()
        
        if selectedCountries.count == 0 {
            collectionTopConstraint.constant = -40
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }
    
    @IBAction func saveAction(_ sender: Any) {
        onSaveSelected?(selectedCountries)
        if dismissPresentingNav {
            navigationController?.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        if dismissPresentingNav {
            navigationController?.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
         }
    }
    
    @IBAction func CloseButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
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
        return filteredCountries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SearchCell
        cell.textlabel.text = filteredCountries?[indexPath.item]
        cell.disclousureImageView.isHidden = dismissOnSelect || multipleSelections
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCountry = filteredCountries?[indexPath.item]
        tableView.deselectRow(at: indexPath, animated: true)
        
        if multipleSelections {
            if let validCountry = selectedCountry {
                if selectedCountries.count == 0 {
                    collectionTopConstraint.constant = 20
                    UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
                }
                if selectedCountries.contains(validCountry) {
                    let message = validCountry + " " + "is already selected".localized
                    toast?.showToastAlert(message, autoHideAfter: 5, type: .info, dismissable: true)
                } else {
                    toast?.hideToast()
                    selectedCountries.insert(validCountry, at: 0)
                    selectedItemsCollectionview.reloadData()
                }
            }
        } else {
            self.onCountrySelected?(selectedCountry ?? "Select a country".localized)
            if dismissOnSelect {
                if let nav = navigationController {
                    nav.popViewController(animated: true)
                } else {
                    dismiss(animated: true)
                }
            } else if dismissPresentingNav {
                navigationController?.dismiss(animated: true)
            }
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
        let matchingTerms = countries?.filter({
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

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let countryCell = cell as? MarketFilterCountryCell  {
            let country = selectedCountries[indexPath.item]
            countryCell.countryLabel.text = country
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedCountries.count
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedCountries.count == 1 {
            collectionTopConstraint.constant = -40
            UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
        }
        selectedCountries.remove(at: indexPath.item)
        let range = Range(uncheckedBounds: (0, collectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        collectionView.reloadSections(indexSet)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let country = selectedCountries[indexPath.item]
        let strigSize = country.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)
            ])
        
        return  CGSize(width: strigSize.width + 40, height: 40)
    }
}

extension SearchViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

class SearchCell: UITableViewCell {
    @IBOutlet weak var textlabel: UILabel!
    @IBOutlet weak var disclousureImageView: UIImageView!
}
