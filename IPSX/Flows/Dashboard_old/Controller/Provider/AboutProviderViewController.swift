//
//  AboutProviderViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 17/09/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class AboutProviderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func openInBrowserAction(_ sender: UIButton) {
        
        if let url = URL(string: Url.aboutProviderUrl) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let dataSource = [["title" : "Your Job as Provider".localized,
                      "subtitle" : "Your Job as Provider Text".localized,
                      "imageName" : "trade"],
                      
                      ["title" : "Providers Dashboard".localized,
                       "subtitle" : "Providers Dashboard Text".localized,
                       "imageName" : "providerDashboard"],
                      
                      ["title" : "Package Builder".localized,
                       "subtitle" : "Package Builder Text".localized,
                       "imageName" : "packageBuilder"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.minimumLineSpacing = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let noOfItems = dataSource.count
        pageControl.numberOfPages = noOfItems
        pageControl.isHidden = !(noOfItems > 1)
        return noOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AboutProviderCellID", for: indexPath) as! AboutProviderCell
        if dataSource.count > indexPath.row {
            let title     = dataSource[indexPath.row]["title"]
            let subtitle  = dataSource[indexPath.row]["subtitle"]
            let imageName = dataSource[indexPath.row]["imageName"]
            cell.configure(title: title, subtitle: subtitle, imageName: imageName)
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height * 0.52
        return CGSize(width: width, height: height)
    }
}

class AboutProviderCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(title: String?, subtitle: String?, imageName: String?) {
        
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
        imageView?.image = UIImage(named: imageName ?? "trade")
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
