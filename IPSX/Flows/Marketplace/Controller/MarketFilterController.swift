//
//  MarketFilterController.swift
//  IPSX
//
//  Created by Calin Chitu on 22/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class MarketFilterController: UIViewController {

    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    @IBOutlet weak var topSeparatorConstraint: NSLayoutConstraint! {
        didSet { topConstraint = topSeparatorConstraint }
    }
    
    @IBOutlet weak var sortOptionsTableView: UITableView!
    @IBOutlet weak var selectedSortOptionLabel: UILabel!
    @IBOutlet weak var countriesCollectionView: UICollectionView!
    @IBOutlet weak var countriesCollectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var priceRangeView: RangeView!
    @IBOutlet weak var searchContriesButton: UIButton!
    @IBOutlet weak var worldwideLabel: RoundedView!
    
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    private let searchSegueID = "SearchCountriesSegueID"
    
    fileprivate let reuseIdentifier = "CountryCellID"
    
    fileprivate var selectedCountries:[String] = []
    fileprivate var availableCountries:[String] = []
    
    fileprivate let sortingOptions = ["Descending SLA", "Ascending SLA", "Descending Price", "Ascending Price", "Descending Duration", "Ascending Duration"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let countries = ProxyManager.shared.proxyCountries  {
            availableCountries = countries
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparatorView, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchContriesButton.isHidden = selectedCountries.count == availableCountries.count
        worldwideLabel.isHidden = selectedCountries.count > 0
    }
    
    @IBAction func sortByAction(_ sender: Any) {
        let newAlpha: CGFloat = sortOptionsTableView.alpha < 1 ? 1.0 : 0.0
        scrollView.isScrollEnabled = newAlpha < 1.0
        UIView.animate(withDuration: 0.25) {
            self.sortOptionsTableView.alpha = newAlpha
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == searchSegueID {
            let searchController = segue.destination as? SearchViewController
            searchController?.countries = availableCountries
            searchController?.multipleSelections = true
            searchController?.selectedCountries = selectedCountries
            searchController?.onSaveSelected = { selected in
                self.selectedCountries = selected
                self.countriesCollectionView.reloadData()
            }
        }
    }
}


extension MarketFilterController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortingOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortOptionCellID", for: indexPath)
        if let sortCell = cell as? MarketFilterSortCell {
            sortCell.sortOptionLabel.text = sortingOptions[indexPath.item]
        }
        return cell
    }
}

extension MarketFilterController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        scrollView.isScrollEnabled = true
        selectedSortOptionLabel.text = sortingOptions[indexPath.item]
        UIView.animate(withDuration: 0.25) {
            self.sortOptionsTableView.alpha = 0
        }
    }
}

extension MarketFilterController: UICollectionViewDataSource {
    
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

extension MarketFilterController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        worldwideLabel.isHidden = selectedCountries.count > 1
        searchContriesButton.isHidden = false
        selectedCountries.remove(at: indexPath.item)
        let range = Range(uncheckedBounds: (0, collectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        collectionView.reloadSections(indexSet)
    }
}

extension MarketFilterController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let country = selectedCountries[indexPath.item]
        let strigSize = country.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)
            ])
        
        return  CGSize(width: strigSize.width + 40, height: 40)
    }
}

extension MarketFilterController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text, topOffset: 44) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topView)
        }
    }
}