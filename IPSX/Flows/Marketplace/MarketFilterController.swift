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
    @IBOutlet weak var countriesCollectionView: UICollectionView!
    
    @IBOutlet weak var priceRangeView: RangeView!
    
    fileprivate let reuseIdentifier = "CountryCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sortByAction(_ sender: Any) {
    }
    
}

extension MarketFilterController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let countries = UserManager.shared.proxyCountries, let countryCell = cell as? MarketFilterCountryCell  {
            let country = countries[indexPath.item]
            countryCell.countryLabel.text = country
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserManager.shared.proxyCountries?.count ?? 0
    }
}

extension MarketFilterController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let countries = UserManager.shared.proxyCountries  {
            let country = countries[indexPath.item]
            let strigSize = country.size(withAttributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)
                ])
            
            return  CGSize(width: strigSize.width + 40, height: 40)


        }
        
        return  CGSize(width: 96, height: 40)
    }
}
