//
//  MarketFilterController.swift
//  IPSX
//
//  Created by Calin Chitu on 22/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


class MarketFilterController: UIViewController {
    
    @IBOutlet weak var activeFiltersConterLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var countriesCollectionView: UICollectionView!
    @IBOutlet weak var countriesCollectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var searchContriesButton: UIButton!
    @IBOutlet weak var worldwideLabel: RoundedView!
    @IBOutlet weak var sortPickerView: UIPickerView!
    @IBOutlet weak var sortPickerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sortPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sortArrowImage: UIImageView!
    @IBOutlet weak var sortButton: UIButton!
    
    //MARK: filter values related outlets
    @IBOutlet weak var selectedSortOptionLabel: UILabel!
    @IBOutlet weak var priceRangeView: RangeView!
    @IBOutlet weak var durationRangeView: RangeView!
    @IBOutlet weak var trafficRangeView: RangeView!
    @IBOutlet weak var slaRangeView: RangeView!
    @IBOutlet weak var bandwithRangeView: RangeView!
    @IBOutlet weak var ipTypeGroupedView: GroupedOptionsView!
    @IBOutlet weak var proxyTypeGroupedView: GroupedOptionsView!
    @IBOutlet weak var offerTypeGroupedView: GroupedOptionsView!
    @IBOutlet weak var featuresMatrixView: GroupedMatrixView!
    
    //MARK: toast alert outlets and vars
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var topSeparatorConstraint: NSLayoutConstraint! {
        didSet { topConstraint = topSeparatorConstraint }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    //MARK: Public properties
    public var filtersDictionary: [String:Any] = [:] {
        didSet {
            activeFiltersConterLabel.textColor = filtersDictionary.values.count > 0 ? UIColor.darkBlue : .warmGrey
            let tailString = filtersDictionary.values.count == 1 ? "Filter active".localized : "Filters active".localized
            activeFiltersConterLabel.text = "\(filtersDictionary.values.count) \(tailString)"
        }
    }
    public var onApplyFilters: ((_ filtersDic: [String:Any])->())?

    //MARK: internal kictchen
    fileprivate let searchSegueID = "SearchCountriesSegueID"
    fileprivate let reuseIdentifier = "CountryCellID"
    fileprivate let unwindToMarketID = "UnwindToMarketSegueID"
    fileprivate var selectedCountries:[String] = []
    fileprivate var availableCountries:[String] = []

    //date, random, traffic, duration, cost (DESC, ASC)
    fileprivate let sortingOptions = [
                                      (title: "Random Descending".localized,   filterKey: "random", orderKey: "DESC"),
                                      (title: "Random Ascending".localized,    filterKey: "random", orderKey: "ASC"),
                                      (title: "Traffic Descending".localized,  filterKey: "traffic", orderKey: "DESC"),
                                      (title: "Traffic Ascending".localized,   filterKey: "traffic", orderKey: "ASC"),
                                      (title: "Date Descending".localized,     filterKey: "date", orderKey: "DESC"),
                                      (title: "Date Ascending".localized,      filterKey: "date", orderKey: "ASC"),
                                      (title: "Duration Descending".localized, filterKey: "duration", orderKey: "DESC"),
                                      (title: "Duration Ascending".localized,  filterKey: "duration", orderKey: "ASC"),
                                      (title: "Cost Descending".localized,     filterKey: "cost", orderKey: "DESC"),
                                      (title: "Cost Ascending".localized,      filterKey: "cost", orderKey: "ASC")
    ]
    private let defaultSortIndex = 4
    private var defaultSortSelected = false
    
    //MARK: viewcontroller delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        activeFiltersConterLabel.text = "\(filtersDictionary.values.count) Filters active"
        observeSliders()
        updatePickerUI(visible: false, animated: false)
        selectedSortOptionLabel.text = sortingOptions[defaultSortIndex].title
        if let countries = UserManager.shared.allCountries  {
            availableCountries = countries.map { item in
                return item.values.first ?? ""}
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
    
    
    //MARK: UIControls actions
    @IBAction func sortByAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !defaultSortSelected {
            sortPickerView.selectRow(defaultSortIndex, inComponent: 0, animated: false)
            defaultSortSelected = true
        }
        updatePickerUI(visible: sender.isSelected)
    }
    
    @IBAction func resetFilters(_ sender: Any) {
        resetSliders()
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        self.onApplyFilters?(filtersDictionary)
        self.performSegue(withIdentifier: unwindToMarketID, sender: self)
    }
    
    
    //MARK: Internal logic
    private func resetSliders() {
        priceRangeView.reset()
        durationRangeView.reset()
        trafficRangeView.reset()
        slaRangeView.reset()
        bandwithRangeView.reset()
    }
    
    private func observeSliders() {
        priceRangeView.onNewState = { activeState, values in
            if activeState {
                self.filtersDictionary["price"] = ["min_price":Int(values.low), "max_price":Int(values.high)]
            }
            else {
                self.filtersDictionary.removeValue(forKey: "price")
            }
        }
    }
    
    private func updatePickerUI(visible: Bool, animated: Bool = true) {
        
        sortButton.isSelected = visible
        sortArrowImage.isHidden = visible
        sortPickerTopConstraint.constant = visible ? 0 : -60
        sortPickerHeightConstraint.constant = visible ? 220 : 60
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
                self.view.layoutIfNeeded()
            })} else {
            self.view.layoutIfNeeded()
        }
    }
    
}


extension MarketFilterController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortingOptions.count
    }
}

extension MarketFilterController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortingOptions[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedSortOptionLabel.text = sortingOptions[row].title
        if row == defaultSortIndex {
            filtersDictionary.removeValue(forKey: "sort")
        } else {
            filtersDictionary["sort"] = ["sort_criteria":sortingOptions[row].filterKey, "sort_order":sortingOptions[row].orderKey]
        }
    }
}


//MARK: Countries collectionview delegate and datasource
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


//MARK: Toast alert protocol
extension MarketFilterController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text, topOffset: 44) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topView)
        }
    }
}
