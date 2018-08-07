//
//  ProxyDetailsViewController.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

@IBDesignable
class ProxyDetailsViewController: UIViewController {
    
    @IBOutlet weak var openSettingsOverlayView: UIView!
    @IBOutlet weak var openSettingsCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }

    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    let activationDetailsCellID = "ActivationDetailsCellID"
    let pacDetailsCellID = "PACDetailsCellID"
    var proxy: Proxy?
    var presentedFromDashboard = false

    @IBAction func DoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    @objc func appWillEnterForeground() {
        updateReachabilityInfo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: tableView, text: "New proxy created! Copy pac link to continue".localized)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !presentedFromDashboard {
            toast?.showToastAlert(type: .info)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }

    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else {
                if self.toast?.currentText == "No internet connection".localized {
                    self.toast?.hideToastAlert()
                }
                self.updateReachabilityInfo()
            }
         }
    }

    func updateReachabilityInfo() {
        DispatchQueue.main.async {
            if self.proxy?.proxyDetails?.status != "active" {
                self.toast?.showToastAlert("Proxy Expired Alert Message".localized, dismissable: false)
            } else  {
                switch ReachabilityManager.shared.connectionType {
                case .wifi:
                    IPService().getPublicIPAddress() { error, ipAddress in
                        DispatchQueue.main.async {
                            if let deviceIp = ipAddress, let proxyIp = self.proxy?.proxyDetails?.userIP {
                                if deviceIp != proxyIp {
                                    let message = String(format: "Device IP %@ Mismatch Alert Message".localized, "\(deviceIp)")
                                    self.toast?.showToastAlert(message, dismissable: false)
                                }
                            }
                        }
                    }
                default:
                    self.toast?.showToastAlert("Connect to WiFi network message".localized, dismissable: false)
                }
            }
        }
    }

    private func configureUI() {
        self.openSettingsOverlayView.alpha = 0
        self.openSettingsCenterConstraint.constant = 500
    }
    
    @IBAction func closeOverlayAction(_ sender: Any) {
        hideOverlay()
    }
    
    @IBAction func openSettingsAction(_ sender: Any) {
        
        guard let settingsUrl = URL(string: "App-Prefs:root=WIFI") else {
            hideOverlay()
            toast?.showToastAlert("Select Valid ETH Wallet Message".localized, type: .error)
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        } else {
            hideOverlay()
            toast?.showToastAlert("Redirect to Settings Error Message".localized, type: .error)
        }
    }
    
    private func hideOverlay() {
        view.layoutIfNeeded()
        self.openSettingsCenterConstraint.constant = 500
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.view.layoutIfNeeded()
            self.openSettingsOverlayView.alpha = 0
        })
    }
}

extension ProxyDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        case 2: return 4
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: activationDetailsCellID, for: indexPath) as! ProxyActivationDetailsCell
            guard let proxy = proxy else { return UITableViewCell() }
            cell.configure(proxy: proxy)
            return cell
          
        case 1:
            switch indexPath.row {
                
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: pacDetailsCellID, for: indexPath) as! ProxyDetailsCell
                cell.configure(title: "PAC link", value: proxy?.proxySetup?.pacLink, allowCopy: proxy?.proxyDetails?.status == "active")
                return cell

            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProxyDetailsCell.cellID, for: indexPath) as! ProxyDetailsCell
                cell.configure(title: "IP", value: proxy?.proxySetup?.proxyIP)
                return cell

            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProxyDetailsCell.cellID, for: indexPath) as! ProxyDetailsCell
                cell.configure(title: "Port", value:  proxy?.proxySetup?.proxyPort)
                return cell

            default:
                return UITableViewCell()
            }
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProxyDetailsCell.cellID, for: indexPath) as! ProxyDetailsCell
            switch indexPath.row {
                
            case 0:
                let startDate = proxy?.proxyDetails?.startDate?.dateToString(format: "dd MMM yyyy") ?? "20 Apr 2018"
                let startHour = proxy?.proxyDetails?.startDate?.dateToString(format: "HH:mm") ?? "12:00"
                cell.configure(title: "Start Date", value: startDate, additionalDetail: startHour)
                return cell
                
            case 1:
                let endDate = proxy?.proxyDetails?.endDate?.dateToString(format: "dd MMM yyyy") ?? "20 Apr 2018"
                let endHour = proxy?.proxyDetails?.endDate?.dateToString(format: "HH:mm") ?? "12:00"
                cell.configure(title: "End Date".localized, value: endDate, additionalDetail: endHour)
                return cell
                
            case 2:
                cell.configure(title: "Country".localized, value: proxy?.proxyDetails?.country)
                return cell
                
            case 3:
                cell.configure(title: "User IP".localized, value:  proxy?.proxyDetails?.userIP)
                return cell
                
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
}

extension ProxyDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(item: 0, section: 1), proxy?.proxyDetails?.status == "active" {
            tableView.deselectRow(at: indexPath, animated: true)
            view.layoutIfNeeded()
            self.openSettingsCenterConstraint.constant = 0
            UIPasteboard.general.string = proxy?.proxySetup?.pacLink ?? "http://ip.sx"
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
                self.view.layoutIfNeeded()
                self.openSettingsOverlayView.alpha = 1
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return UITableView.IPSXTableViewDefault.bigRowHeight
        case 1,2:
            return UITableView.IPSXTableViewDefault.smallRowHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var title = ""
        switch section {
        case 1: title = "Proxy"
        case 2: title = "Other Details"
        default: return nil
        }
        return tableView.standardHeaderView(withTitle: title)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 1,2: return UITableView.IPSXTableViewDefault.sectionHeaderHeight
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        switch section {
        case 2: return UITableView.IPSXTableViewDefault.bigRowHeight
        default: return 0.01
        }
    }
}

extension ProxyDetailsViewController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}
