//
//  MarketFilterController.swift
//  IPSX
//
//  Created by Calin Chitu on 22/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

struct FilterKeys {
    //root keys for sort and location
    static let sort     = (root: "sort", criteria: "order_by", order: "order", row : "sort_row")
    static let location = (root: "location")
    
    //root keys for sliders
    static let price     = (root: "price",     min: "ips_min",       max: "ips_max")
    static let duration  = (root: "duration",  min: "duration_min",  max: "duration_max")
    static let traffic   = (root: "traffic",   min: "min_traffic",   max: "max_traffic")
    static let sla       = (root: "sla",       min: "sla_min",       max: "sla_max")
    static let bandwidth = (root: "bandwidth", min: "min_bandwidth", max: "max_bandwidth")
    
    static let sliderRootkeys = [price, duration, traffic, sla, bandwidth]
    
    //root keys for grouped views
    static let ip_type    = (root: "ip_type",    first: "4",         second: "6")
    static let proxy_type = (root: "proxy_type", first: "dedicated", second: "shared")
    static let offer_type = (root: "offer_type", first: "group",     second: "single")

    //root key for matrix
    static let features = (root: "features", r1c1: "http(s)", r1c2: "socks5", r2c1: "vpn", r2c2: "shadowsocks")
    
    static let sortingOptions = [
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
}


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
    
    public var onApplyFilters: ((_ filtersDic: [String:Any], _ filtersNormalisedDic: [String:Any])->())?

    //MARK: internal kictchen
    fileprivate let searchSegueID = "SearchCountriesSegueID"
    fileprivate let reuseIdentifier = "CountryCellID"
    fileprivate let unwindToMarketID = "UnwindToMarketSegueID"
    fileprivate var selectedCountries:[String] = [] {
        didSet {
            if selectedCountries.count > 0 {
                filtersDictionary[FilterKeys.location.root] = selectedCountries
            } else {
                filtersDictionary.removeValue(forKey: FilterKeys.location.root)
            }
            worldwideLabel.isHidden = selectedCountries.count > 0
            countriesCollectionView.reloadData()
        }
    }
    fileprivate var availableCountries:[String] = []

    private let defaultSortIndex = 4
    private var defaultSortSelected = false
    
    //MARK: viewcontroller delegates
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let tailString = filtersDictionary.values.count == 1 ? "Filter active".localized : "Filters active".localized
        activeFiltersConterLabel?.text = "\(filtersDictionary.values.count) \(tailString)"
        activeFiltersConterLabel?.textColor = filtersDictionary.values.count > 0 ? UIColor.darkBlue : .warmGrey
        observeSliders()
        observeGroupedViews()
        updatePickerUI(visible: false, animated: false)
        selectedSortOptionLabel.text = FilterKeys.sortingOptions[defaultSortIndex].title
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
        selectedSortOptionLabel.text = FilterKeys.sortingOptions[defaultSortIndex].title
        sortPickerView.selectRow(defaultSortIndex, inComponent: 0, animated: true)
        filtersDictionary.removeValue(forKey: FilterKeys.sort.root)
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        self.onApplyFilters?(filtersDictionary, normalisedFilters(sourceDic: filtersDictionary))
        DispatchQueue.main.async { self.performSegue(withIdentifier: self.unwindToMarketID, sender: self) }
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
            self.updateFiltersDictionary(activeState: activeState,
                                         key: FilterKeys.price.root, values: [FilterKeys.price.min : Int(values.low),
                                                  FilterKeys.price.max : Int(values.high)])
        }
        durationRangeView.onNewState = { activeState, values in
            self.updateFiltersDictionary(activeState: activeState,
                                         key: FilterKeys.duration.root,
                                         values: [FilterKeys.duration.min : Int(values.low), FilterKeys.duration.max : Int(values.high)])
        }
        trafficRangeView.onNewState = { activeState, values in
            self.updateFiltersDictionary(activeState: activeState,
                                         key: FilterKeys.traffic.root,
                                         values: [FilterKeys.traffic.min : Int(values.low), FilterKeys.traffic.max : Int(values.high)])
        }
        slaRangeView.onNewState = { activeState, values in
            self.updateFiltersDictionary(activeState: activeState,
                                         key: FilterKeys.sla.root,
                                         values: [FilterKeys.sla.min : Int(values.low), FilterKeys.sla.max : Int(values.high)])
        }
        bandwithRangeView.onNewState = { activeState, values in
            self.updateFiltersDictionary(activeState: activeState,
                                         key: FilterKeys.bandwidth.root,
                                         values: [FilterKeys.bandwidth.min : Int(values.low), FilterKeys.bandwidth.max : Int(values.high)])
        }
    }
    
    private func observeGroupedViews() {
        ipTypeGroupedView.onNewState = { activeState, values in
            var vals: [String] = []
            if values.first { vals.append(FilterKeys.ip_type.first)}
            if values.second { vals.append(FilterKeys.ip_type.second)}
            self.updateFiltersDictionary(activeState: activeState, key: FilterKeys.ip_type.root, values: vals)
        }
        proxyTypeGroupedView.onNewState = { activeState, values in
            var vals: [String] = []
            if values.first { vals.append(FilterKeys.proxy_type.first)}
            if values.second { vals.append(FilterKeys.proxy_type.second)}
            self.updateFiltersDictionary(activeState: activeState, key: FilterKeys.proxy_type.root, values: vals)
        }
        offerTypeGroupedView.onNewState = { activeState, values in
            var vals: [String] = []
            if values.first { vals.append(FilterKeys.offer_type.first)}
            if values.second { vals.append(FilterKeys.offer_type.second)}
            self.updateFiltersDictionary(activeState: activeState, key: FilterKeys.offer_type.root, values: vals)
        }
        featuresMatrixView.onNewState = { activeState, values in
            var vals: [String] = []
            if values.r1c1 { vals.append(FilterKeys.features.r1c1)}
            if values.r1c2 { vals.append(FilterKeys.features.r1c2)}
            if values.r2c1 { vals.append(FilterKeys.features.r2c1)}
            if values.r2c2 { vals.append(FilterKeys.features.r2c2)}
            self.updateFiltersDictionary(activeState: activeState, key: FilterKeys.features.root, values: vals)
        }
    }

    private func loadFilterValues() {
        if let selCountries = filtersDictionary[FilterKeys.location.root] as? [String], selCountries.count > 0 {
            selectedCountries = selCountries
        }
        if let sortDic = filtersDictionary[FilterKeys.sort.root] as? [String:Any],
            let sortRow = sortDic[FilterKeys.sort.row] as? Int {
            defaultSortSelected = true
            sortPickerView.selectRow(sortRow, inComponent: 0, animated: false)
            selectedSortOptionLabel.text = FilterKeys.sortingOptions[sortRow].title
        }
        if let prices = filtersDictionary[FilterKeys.price.root] as? [String:Int],
            let min = prices[FilterKeys.price.min],
            let max = prices[FilterKeys.price.max] {
            priceRangeView.updateSlider(lower: Double(min) / priceRangeView.maxVal, upper: Double(max) / priceRangeView.maxVal)
        }
        if let durations = filtersDictionary[FilterKeys.duration.root] as? [String:Int],
            let min = durations[FilterKeys.duration.min],
            let max = durations[FilterKeys.duration.max] {
            durationRangeView.updateSlider(lower: Double(min) / durationRangeView.maxVal, upper: Double(max) / durationRangeView.maxVal)
        }
        if let traffics = filtersDictionary[FilterKeys.traffic.root] as? [String:Int],
            let min = traffics[FilterKeys.traffic.min],
            let max = traffics[FilterKeys.traffic.max] {
            trafficRangeView.updateSlider(lower: Double(min) / trafficRangeView.maxVal, upper: Double(max) / trafficRangeView.maxVal)
        }
        if let slas = filtersDictionary[FilterKeys.sla.root] as? [String:Int],
            let min = slas[FilterKeys.sla.min],
            let max = slas[FilterKeys.sla.max] {
            slaRangeView.updateSlider(lower: Double(min) / slaRangeView.maxVal, upper: Double(max) / slaRangeView.maxVal)
        }
        if let bandwiths = filtersDictionary[FilterKeys.bandwidth.root] as? [String:Int],
            let min = bandwiths[FilterKeys.bandwidth.min],
            let max = bandwiths[FilterKeys.bandwidth.max] {
            bandwithRangeView.updateSlider(lower: Double(min) / bandwithRangeView.maxVal, upper: Double(max) / bandwithRangeView.maxVal)
        }
        if let offertypes = filtersDictionary[FilterKeys.ip_type.root] as? [String] {
            let first = offertypes.contains(FilterKeys.ip_type.first)
            let secound = offertypes.contains(FilterKeys.ip_type.second)
            ipTypeGroupedView.updateSelection(first: first, second: secound)
        }
        if let offertypes = filtersDictionary[FilterKeys.proxy_type.root] as? [String] {
            let first = offertypes.contains(FilterKeys.proxy_type.first)
            let secound = offertypes.contains(FilterKeys.proxy_type.second)
            proxyTypeGroupedView.updateSelection(first: first, second: secound)
        }
        if let offertypes = filtersDictionary[FilterKeys.offer_type.root] as? [String] {
            let first = offertypes.contains(FilterKeys.offer_type.first)
            let secound = offertypes.contains(FilterKeys.offer_type.second)
            offerTypeGroupedView.updateSelection(first: first, second: secound)
        }
        if let features = filtersDictionary[FilterKeys.features.root] as? [String] {
            let r1c1 = features.contains(FilterKeys.features.r1c1)
            let r1c2 = features.contains(FilterKeys.features.r1c2)
            let r2c1 = features.contains(FilterKeys.features.r2c1)
            let r2c2 = features.contains(FilterKeys.features.r2c2)
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
    
    private func normalisedFilters(sourceDic: [String : Any]) -> [String : Any] {
        var resultDic = sourceDic
        if let sortDic = resultDic[FilterKeys.sort.root] as? [String:Any] {
            resultDic.removeValue(forKey: FilterKeys.sort.root)
            resultDic[FilterKeys.sort.order] = sortDic[FilterKeys.sort.order]
            resultDic[FilterKeys.sort.criteria] = sortDic[FilterKeys.sort.criteria]
        }
        for sliderKey in FilterKeys.sliderRootkeys {
            if let sliderDic = resultDic[sliderKey.root] as? [String:Any] {
                resultDic.removeValue(forKey: sliderKey.root)
                resultDic[sliderKey.min] = sliderDic[sliderKey.min]
                resultDic[sliderKey.max] = sliderDic[sliderKey.max]
            }
        }
        return resultDic
    }

}

extension MarketFilterController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return FilterKeys.sortingOptions.count
    }
}

extension MarketFilterController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return FilterKeys.sortingOptions[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedSortOptionLabel.text = FilterKeys.sortingOptions[row].title
        if row == defaultSortIndex {
            filtersDictionary.removeValue(forKey: FilterKeys.sort.root)
        } else {
            filtersDictionary[FilterKeys.sort.root] = [FilterKeys.sort.criteria : FilterKeys.sortingOptions[row].filterKey,
                                                       FilterKeys.sort.order    : FilterKeys.sortingOptions[row].orderKey,
                                                       FilterKeys.sort.row      : row]
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
