//
//  SimpleWebView.swift
//  IPSX
//
//  Created by Calin Chitu on 15/06/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import WebKit

class SimpleWebView: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var webViewHolder: UIView!
    
    var webView: WKWebView!
    
    //Update in prepareForSegeue if the screen is reused
    var loadingURLString: String? = "https://devapp.ip.sx/webview/faq/staking"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView()
        webView.navigationDelegate = self
        
        if let stringUrl = loadingURLString, let url = URL(string: stringUrl) {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
         }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        loadingView.startAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        webView.frame = webViewHolder.bounds
        webViewHolder.addSubview(webView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.stopAnimating()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
}
