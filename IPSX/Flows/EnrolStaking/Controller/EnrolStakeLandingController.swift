//
//  EnrolStakeLandingController.swift
//  IPSX
//
//  Created by Calin Chitu on 28/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EnrolStakeLandingController: UIViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationWebController = segue.destination as? SimpleWebView {
            destinationWebController.loadingURLString = Url.faqPageUrl
            destinationWebController.titleString = "FAQ".localized
        }
    }

}
