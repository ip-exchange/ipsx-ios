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
    let newProxyFlowID = "NewProxyFlowSegueID"
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingView: CustomLoadingView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var errorMessage: String? {
        didSet { self.toast?.showToastAlert(self.errorMessage) }
    }

    public var dismissOnSelect = false
    
    var isProxyFlow: Bool? = false
    var proxyPack: ProxyPack?
    var proxy: Proxy?
    var countries: [String]?
    var filteredCountries: [String]?
    var selectedCountry: String?
    
    private var countriesRefreshed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.isHidden = (isProxyFlow == false)
        backButton.isHidden  = !closeButton.isHidden
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        filteredCountries = isProxyFlow == true ? [] : countries
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        if isProxyFlow == true && proxy == nil {
            
            let calendar = Calendar.current
            let minDurationString = proxyPack?.duration ?? "0"
            let endDate = calendar.date(byAdding: .minute, value: Int(minDurationString) ?? 0, to: Date())
            let proxyDetails = ProxyActivationDetails(startDate: Date(), endDate: endDate, country: "")
            proxy = Proxy(proxyPack: proxyPack, proxyDetails: proxyDetails)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: searchView, text: "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        if isProxyFlow == true, !countriesRefreshed {
            proxyCountryList()
            countriesRefreshed = true
        }
    }
    
    func proxyCountryList() {
        
        loadingView.startAnimating()
        ProxyService().getProxyCountryList(completionHandler: { result in
            
            self.loadingView.stopAnimating()
            switch result {
            case .success(let countryList):
                UserManager.shared.proxyCountries = countryList as? [String]
                self.filteredCountries = UserManager.shared.proxyCountries
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(_):
                self.errorMessage = "Proxy Contries Fetch Error Message".localized
                self.filteredCountries = self.countries
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }

    @IBAction func BackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func CloseButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == newProxyFlowID, let nextVC = segue.destination as? ProxySummaryViewController {
            nextVC.proxy = proxy
        }
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
        return filteredCountries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SearchCell
        cell.textlabel.text = filteredCountries?[indexPath.item]
        cell.disclousureImageView.isHidden = dismissOnSelect
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCountry = filteredCountries?[indexPath.item]
        if dismissOnSelect {
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
        } else if isProxyFlow == true {
            proxy?.proxyDetails?.country = selectedCountry ?? ""
            performSegue(withIdentifier: newProxyFlowID, sender: nil)
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
