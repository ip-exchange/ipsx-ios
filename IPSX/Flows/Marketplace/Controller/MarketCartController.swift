//
//  MarketCartController.swift
//  IPSX
//
//  Created by Calin Chitu on 21/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import IPSXNetworkingFramework

class MarketCartController: UIViewController {

    @IBOutlet weak var headerTotalBalanceLabel: UILabel!
    @IBOutlet weak var offersCounterLabel: UILabel! //2 offers
    @IBOutlet weak var footerTotalLabel: UILabel!
    @IBOutlet weak var footerVATLabel: UILabel!
    @IBOutlet weak var footerSubtotalLabel: UILabel!
    @IBOutlet weak var bottomTotalLabel: UILabel!
    @IBOutlet weak var botttomPriceTitleLabel: UILabel!
    @IBOutlet weak var bottomIpsxIcon: UIImageView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var checkoutButton: RoundedButton!
    @IBOutlet weak var tableView: UITableView!
    
    //TODO (CC): move to offer details
    @IBOutlet weak var noWalletView: RoundedView!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var loadingView: CustomLoadingView!
    
    @IBOutlet weak var topSeparatorConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint = topSeparatorConstraint
        }
    }
    
    var errorMessage: String? {
        didSet {
            if let toast = toast {
                toast.showToastAlert(self.errorMessage, autoHideAfter: 5)
                errorMessage = nil
            }
        }
    }
    
    var cart: Cart?
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    
    private var backFromSegue = false
    fileprivate let cellID = "MarketCellID"
    fileprivate let marketItemID = "MarketItemSegueID"
    private let checkoutSegueID = "CheckoutSegueID"
    private let addWalletSegueID = "AddWalletSegueID"
    private let createDepositSegueID = "CreateDepositSegue"
    private var selectedOffer: Offer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        
        tableView.layer.cornerRadius = 5
        self.bottomTotalLabel.alpha = 0
        self.botttomPriceTitleLabel.alpha = 0
        self.bottomIpsxIcon.alpha = 0
        //TODO (CC): pt isEnabled = false trebuie sa fie greyed out
        self.checkoutButton.isEnabled = cart?.ipsxTotal != 0
        //TODO (CC): move to offer details
        self.noWalletView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparator, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        guard !backFromSegue else {
            backFromSegue = false
            return
        }
        
        self.tableView.alpha = 0
        performViewCartRequest()
        headerTotalBalanceLabel.text = UserManager.shared.userInfo?.balance?.cleanString ?? "0"
        offersCounterLabel.text = "\(cart?.offers.count ?? 0) " + "offers".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if errorMessage != nil { toast?.showToastAlert(self.errorMessage, autoHideAfter: 5) }
    }
    
    @IBAction func editAction(_ sender: UIButton) {
    
        sender.isSelected = !sender.isSelected
        tableView.reloadData()
    }
    
    @IBAction func checkout(_ sender: Any) {
        
        if UserManager.shared.userInfo?.balance ?? 0 < cart?.ipsxTotal ?? 0 {
            self.errorMessage = "Insufficient Balance Error Message".localized
        }
        else {
            performSegue(withIdentifier: checkoutSegueID, sender: self)
        }
    }
    
    @IBAction func createNewDeposit(_ sender: Any) {
        performSegue(withIdentifier: "CreateDepositSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        backFromSegue = true
        
        switch segue.identifier {
            
        case addWalletSegueID:
            let addWalletController = segue.destination as? WalletAddController
            addWalletController?.shouldPop = true
            
        case marketItemID:
            let itemController = segue.destination as? MarketItemController
            itemController?.isInCartAlready = true
            itemController?.offer = selectedOffer
            
        case createDepositSegueID:
            let dest = segue.destination as? ViewGeneratedAdrressController
            dest?.shouldDismiss = true
            
        case checkoutSegueID:
            let dest = segue.destination as? MarketCheckoutController
            dest?.cart = cart
            
        default: break
        }
    }
    
    func configureSummaryUI() {
        
        offersCounterLabel.text = "\(cart?.offers.count ?? 0) " + "offers".localized
        footerSubtotalLabel.text = cart?.ipsxSubtotal.cleanString
        footerVATLabel.text      = cart?.ipsxVat.cleanString
        footerTotalLabel.text    = cart?.ipsxTotal.cleanString
        bottomTotalLabel.text    = cart?.ipsxTotal.cleanString
    }
    
    func performViewCartRequest() {
        
        loadingView?.startAnimating()
        ProxyManager.shared.cart = nil
        MarketplaceService().viewCart(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(let cart):
                
                self.cart = cart as? Cart
                ProxyManager.shared.cart = self.cart
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) { self.tableView.alpha = 1 }
                    let items = self.cart?.offers.count ?? 0
                    self.updateBottomLabels(alpha: items < 3 ? 0 : 1)
                    self.configureSummaryUI()
                    self.tableView.reloadData()
                }
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.viewCart, completion: {
                    self.performViewCartRequest()
                })
            }
        })
    }
    
    func performDeleteRequest(offerIds: [Int]) {
        
        loadingView?.startAnimating()
        MarketplaceService().deleteFromCart(offerIds: offerIds, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                self.performViewCartRequest()
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.deleteFromCart, completion: {
                    self.performDeleteRequest(offerIds: offerIds)
                })
            }
        })
    }
    
    func updateBottomLabels(alpha: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.bottomTotalLabel.alpha = alpha
            self.botttomPriceTitleLabel.alpha = alpha
            self.bottomIpsxIcon.alpha = alpha
        }
    }
    
    @IBAction func unwindToCart(segue:UIStoryboardSegue) {}
}

extension MarketCartController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart?.offers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MarketCell
        if cart?.offers.count ?? 0 > indexPath.row, let offer = cart?.offers[indexPath.row] {
            cell.configure(offer: offer, editMode: editButton.isSelected)
        }
        
        cell.onDelete = { offer in
            
            self.performDeleteRequest(offerIds: [offer.id])
            
            if let filtered = self.cart?.offers.filter({ $0.id != offer.id }) {
                self.cart?.offers = filtered
            }
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        }
        return cell
    }
}

extension MarketCartController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedOffer = cart?.offers[indexPath.row]
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.marketItemID, sender: self)
        }
    }
}

extension MarketCartController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

extension MarketCartController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completion:(() -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            self.errorMessage = "Generic Error Message".localized
        }
    }
}
