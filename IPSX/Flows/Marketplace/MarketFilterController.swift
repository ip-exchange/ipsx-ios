//
//  MarketFilterController.swift
//  IPSX
//
//  Created by Calin Chitu on 22/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class MarketFilterController: UIViewController {

    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    @IBOutlet weak var scrollTopConstraint: NSLayoutConstraint! {
        didSet { topConstraint = scrollTopConstraint }
    }
    
    @IBOutlet weak var countriesCollectionView: UICollectionView!
    @IBOutlet weak var countriesCollectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var priceRangeView: RangeView!
    @IBOutlet weak var searchContriesButton: UIButton!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    private let searchSegueID = "SearchCountriesSegueID"
    
    fileprivate let reuseIdentifier = "CountryCellID"
    
    fileprivate var countriesList:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let countries = ProxyManager.shared.proxyCountries  {
            countriesList = countries
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: scrollContentView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let countries = ProxyManager.shared.proxyCountries, countriesList.count == countries.count  {
            searchContriesButton.isHidden = true
        }
    }
    
    @IBAction func sortByAction(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == searchSegueID {
            let searchController = segue.destination as? SearchViewController
            searchController?.onCountrySelected = { selectedCountry in
            }
            searchController?.countries = countriesList
        }
    }
}

extension MarketFilterController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let countryCell = cell as? MarketFilterCountryCell  {
            let country = countriesList[indexPath.item]
            countryCell.countryLabel.text = country
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countriesList.count
    }
}

extension MarketFilterController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard countriesList.count > 1000 else {
            toast?.showToastAlert("You need at least one country in your list", autoHideAfter: 5, type: .info, dismissable: true)
            return
        }
        searchContriesButton.isHidden = false
        countriesList.remove(at: indexPath.item)
        let range = Range(uncheckedBounds: (0, collectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        collectionView.reloadSections(indexSet)
    }
}

extension MarketFilterController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let country = countriesList[indexPath.item]
        let strigSize = country.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)
            ])
        
        return  CGSize(width: strigSize.width + 40, height: 40)
    }
}

extension MarketFilterController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text, topOffset: 20) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: scrollContentView)
        }
    }
}
