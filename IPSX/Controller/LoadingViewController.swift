//
//  LoadingViewController.swift
//  IPSX
//
//  Created by Calin Chitu on 15/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import WebKit

class LoadingViewController: UIViewController, WKUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        webView.uiDelegate = self
        view.insertSubview(webView, at: 0)
        
        if let url = Bundle.main.url(forResource: "background", withExtension: "html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.performSegue(withIdentifier: "TabbarSegueID", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
