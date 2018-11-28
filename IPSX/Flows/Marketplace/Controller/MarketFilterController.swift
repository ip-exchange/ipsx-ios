//
//  MarketFilterController.swift
//  IPSX
//
//  Created by Calin Chitu on 22/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class MarketFilterController: UIViewController {
    
    @IBOutlet weak var activeFiltersConterLabel: UILabel?
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
        didSet { updateCounterUI() }
    }
    
    public var onApplyFilters: ((_ filtersDic: [String:Any])->())?

    //MARK: internal kictchen
    fileprivate let searchSegueID = "SearchCountriesSegueID"
    fileprivate let reuseIdentifier = "CountryCellID"
    fileprivate let unwindToMarketID = "UnwindToMarketSegueID"
    fileprivate var selectedCountries:[String] = [] {
        didSet {
            if selectedCountries.count > 0 {
                filtersDictionary["location"] = selectedCountries
            } else {
                filtersDictionary.removeValue(forKey: "location")
            }
            worldwideLabel.isHidden = selectedCountries.count > 0
            countriesCollectionView.reloadData()
        }
    }
    fileprivate var availableCountries:[String] = []

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
        activeFiltersConterLabel?.text = "\(filtersDictionary.values.count) Filters active"
        activeFiltersConterLabel?.textColor = filtersDictionary.values.count > 0 ? UIColor.darkBlue : .warmGrey
        observeSliders()
        observeGroupedViews()
        updatePickerUI(visible: false, animated: false)
        selectedSortOptionLabel.text = sortingOptions[defaultSortIndex].title
        if let countries = UserManager.shared.allCountries  {
            availableCountries = countries.map { item in
                return item.values.first ?? ""}
        }
        loadFilterValues()
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
        resetGroupedViews()
        selectedCountries = []
        selectedSortOptionLabel.text = sortingOptions[defaultSortIndex].title
        sortPickerView.selectRow(defaultSortIndex, inComponent: 0, animated: true)
        filtersDictionary.removeValue(forKey: "sort")
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
    
    private func resetGroupedViews() {
        ipTypeGroupedView.reset()
        proxyTypeGroupedView.reset()
        offerTypeGroupedView.reset()
        featuresMatrixView.reset()
    }
    
    private func observeSliders() {
        priceRangeView.onNewState = { activeState, values in
            self.updateFiltersDictionary(activeState: activeState, key: "price", values: ["min_price":Int(values.low), "max_price":Int(values.high)])
        }
        durationRangeView.onNewState = { activeState, values in
            self.updateFiltersDictionary(activeState: activeState, key: "duration", values: ["min_duration":Int(values.low), "max_duration":Int(values.high)])
        }
        trafficRangeView.onNewState = { activeState, values in
            self.updateFiltersDictionary(activeState: activeState, key: "traffic", values: ["min_traffic":Int(values.low), "max_traffic":Int(values.high)])
        }
        slaRangeView.onNewState = { activeState, values in
            self.updateFiltersDictionary(activeState: activeState, key: "sla", values: ["min_sla":Int(values.low), "max_sla":Int(values.high)])
        }
        bandwithRangeView.onNewState = { activeState, values in
            self.updateFiltersDictionary(activeState: activeState, key: "bandwidth", values: ["min_bandwidth":Int(values.low), "max_bandwidth":Int(values.high)])
        }
    }
    
    private func observeGroupedViews() {
        ipTypeGroupedView.onNewState = { activeState, values in
            var vals: [String] = []
            if values.first { vals.append("4")}
            if values.second { vals.append("6")}
            self.updateFiltersDictionary(activeState: activeState, key: "ip_type", values: vals)
        }
        proxyTypeGroupedView.onNewState = { activeState, values in
            var vals: [String] = []
            if values.first { vals.append("dedicated")}
            if values.second { vals.append("shared")}
            self.updateFiltersDictionary(activeState: activeState, key: "proxy_type", values: vals)
        }
        offerTypeGroupedView.onNewState = { activeState, values in
            var vals: [String] = []
            if values.first { vals.append("single")}
            if values.second { vals.append("group")}
            self.updateFiltersDictionary(activeState: activeState, key: "offer_type", values: vals)
        }
        featuresMatrixView.onNewState = { activeState, values in
            var vals: [String] = []
            if values.r1c1 { vals.append("http(s)")}
            if values.r1c2 { vals.append("socks5")}
            if values.r2c1 { vals.append("vpn")}
            if values.r2c2 { vals.append("shadowsocks")}
            self.updateFiltersDictionary(activeState: activeState, key: "features", values: vals)
        }
    }

    private func loadFilterValues() {
        if let selCountries = filtersDictionary["location"] as? [String], selCountries.count > 0 {
            selectedCountries = selCountries
        }
        if let sortDic = filtersDictionary["sort"] as? [String:Any], let sortRow = sortDic["sort_row"] as? Int {
            defaultSortSelected = true
            sortPickerView.selectRow(sortRow, inComponent: 0, animated: false)
            selectedSortOptionLabel.text = sortingOptions[sortRow].title
        }
        if let prices = filtersDictionary["price"] as? [String:Int], let min = prices["min_price"], let max = prices["max_price"] {
            priceRangeView.updateSlider(lower: Double(min) / priceRangeView.maxVal, upper: Double(max) / priceRangeView.maxVal)
        }
        if let durations = filtersDictionary["duration"] as? [String:Int], let min = durations["min_duration"], let max = durations["max_duration"] {
            durationRangeView.updateSlider(lower: Double(min) / durationRangeView.maxVal, upper: Double(max) / durationRangeView.maxVal)
        }
        if let traffics = filtersDictionary["traffic"] as? [String:Int], let min = traffics["min_traffic"], let max = traffics["max_traffic"] {
            trafficRangeView.updateSlider(lower: Double(min) / trafficRangeView.maxVal, upper: Double(max) / trafficRangeView.maxVal)
        }
        if let slas = filtersDictionary["sla"] as? [String:Int], let min = slas["min_sla"], let max = slas["max_sla"] {
            slaRangeView.updateSlider(lower: Double(min) / slaRangeView.maxVal, upper: Double(max) / slaRangeView.maxVal)
        }
        if let bandwiths = filtersDictionary["bandwidth"] as? [String:Int], let min = bandwiths["min_bandwidth"], let max = bandwiths["max_bandwidth"] {
            bandwithRangeView.updateSlider(lower: Double(min) / bandwithRangeView.maxVal, upper: Double(max) / bandwithRangeView.maxVal)
        }
        if let offertypes = filtersDictionary["ip_type"] as? [String] {
            let first = offertypes.contains("4")
            let secound = offertypes.contains("6")
            ipTypeGroupedView.updateSelection(first: first, second: secound)
        }
        if let offertypes = filtersDictionary["offer_type"] as? [String] {
            let first = offertypes.contains("single")
            let secound = offertypes.contains("group")
            offerTypeGroupedView.updateSelection(first: first, second: secound)
        }
        if let offertypes = filtersDictionary["proxy_type"] as? [String] {
            let first = offertypes.contains("dedicated")
            let secound = offertypes.contains("shared")
            proxyTypeGroupedView.updateSelection(first: first, second: secound)
        }
        if let features = filtersDictionary["features"] as? [String] {
            let r1c1 = features.contains("http(s)")
            let r1c2 = features.contains("socks5")
            let r2c1 = features.contains("vpn")
            let r2c2 = features.contains("shadowsocks")
            featuresMatrixView.updateSelection(r1c1: r1c1, r1c2: r1c2, r2c1: r2c1, r2c2: r2c2)
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
    
    private func updateCounterUI() {
        activeFiltersConterLabel?.textColor = filtersDictionary.values.count > 0 ? UIColor.darkBlue : .warmGrey
        let tailString = filtersDictionary.values.count == 1 ? "Filter active".localized : "Filters active".localized
        activeFiltersConterLabel?.text = "\(filtersDictionary.values.count) \(tailString)"
    }

    private func updateFiltersDictionary(activeState: Bool, key: String, values: Any) {
        if activeState {
            self.filtersDictionary[key] = values
        }
        else {
            self.filtersDictionary.removeValue(forKey: key)
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
            filtersDictionary["sort"] = ["sort_criteria":sortingOptions[row].filterKey, "sort_order":sortingOptions[row].orderKey, "sort_row": row]
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
