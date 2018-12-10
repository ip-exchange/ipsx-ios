//
//  ProxyItemCollectionViewCell.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class ProxyItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: ProgressRoundView!
    @IBOutlet weak var httpImageView: UIImageView!
    @IBOutlet weak var httpLabel: UILabel!
    @IBOutlet weak var socks5ImageView: UIImageView!
    @IBOutlet weak var socks5Label: UILabel!
    @IBOutlet weak var vpnImageView: UIImageView!
    @IBOutlet weak var vpnLabel: UILabel!
    @IBOutlet weak var shadowsocksImageView: UIImageView!
    @IBOutlet weak var shadowsocksLabel: UILabel!
    
    @IBOutlet weak var packNameLabel: UILabel?
    
    var onCopy: ((_ : String, _ : String)->())?
    
    @IBAction func copyAction(_ sender: Any) {
        onCopy?(proxyName, proxyUrl)
    }
    
    private var proxyName = "1122334455.pac" //TODO - set in configure
    private var proxyUrl = "url://balbla" //TODO - set in configure
    
    func configure(proxy: Proxy) {
        
        initialConfig()
        
        flagImageView.image = UIImage(named: "worldPins")
        if let flagUrl = URL(string: proxy.flagUrlName),
            let flagImage = UIImage(named: flagUrl.deletingPathExtension().lastPathComponent) {
            flagImageView.image = flagImage
        }
        countryLabel.text = proxy.countryName
        progressView.progress = Double(proxy.sla)
        progressLabel.text = "\(proxy.sla)%"
        
        configureFeatures(proxy: proxy)
    }
    
    private func configureFeatures(proxy: Proxy) {
        
        for feature in proxy.features {
            
            switch feature.uppercased() {
                
            case "HTTP(S)":
                httpImageView.tintColor = .darkGray
                httpLabel.textColor = .darkGray
                
            case "SOCKS5":
                socks5ImageView.tintColor = .darkGray
                socks5Label.textColor = .darkGray
                
            case "VPN":
                vpnImageView.tintColor = .darkGray
                vpnLabel.textColor = .darkGray
                
            case "SHADOWSOCKS":
                shadowsocksImageView.tintColor = .darkGray
                shadowsocksLabel.textColor = .darkGray
                
            default: break
            }
        }
    }
    
    private func initialConfig() {
        
        httpImageView.tintColor = .disabledGrey
        socks5ImageView.tintColor = .disabledGrey
        vpnImageView.tintColor = .disabledGrey
        shadowsocksImageView.tintColor = .disabledGrey
    }
    
}
