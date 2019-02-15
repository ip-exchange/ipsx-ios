//
//  MarketCartController.swift
//  IPSX
//
//  Created by Calin Chitu on 21/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit


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
    @IBOutlet weak var createDepositButton: UIButton!
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
    
    var cart: Cart? {
        didSet {
            DispatchQueue.main.async {
                self.checkoutButton.isEnabled = self.cart != nil && self.cart?.summary?.ipsxTotal != 0
            }
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var onDataChanged: (()->())?
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
        createDepositButton.isEnabled = UserManager.shared.roles?.contains(.Requester) == true
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
        
        if let unavalables = cart?.offers.filter({ $0.isAvailable == false }), unavalables.count > 0 {
            self.toast?.showToastAlert("Remove Unavailable Offers Alert".localized, autoHideAfter: 5, type: .info, dismissable: true)
        } else if UserManager.shared.userInfo?.balance ?? 0 < cart?.summary?.ipsxTotal ?? 0 {
            self.errorMessage = "Insufficient Balance Error Message".localized
        }
        else {
            DispatchQueue.main.async { self.performSegue(withIdentifier: self.checkoutSegueID, sender: self) }
        }
    }
    
    @IBAction func createNewDeposit(_ sender: Any) {
        DispatchQueue.main.async { self.performSegue(withIdentifier: "CreateDepositSegue", sender: self) }
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
            onDataChanged?()
            
        default: break
        }
    }
    
    func configureSummaryUI() {
        
        let noOfOffers = cart?.offers.count ?? 0
        if noOfOffers == 1 {
            offersCounterLabel.text = "\(noOfOffers) " + "offer".localized
        }
        else {
            offersCounterLabel.text = "\(noOfOffers) " + "offers".localized
        }
        footerSubtotalLabel.text = cart?.summary?.ipsxSubtotal.cleanString
        footerVATLabel.text      = cart?.summary?.ipsxVat.cleanString
        footerTotalLabel.text    = cart?.summary?.ipsxTotal.cleanString
        bottomTotalLabel.text    = cart?.summary?.ipsxTotal.cleanString
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
                    
                    if self.cart?.offers.count == 0 {
                        self.editButton.isEnabled = false
                        self.editButton.isSelected = false
                    }

                }
            case .failure(let error):
                
                let completionError: ((String) -> ()) = { [weak self] errorMessage in
                    self?.errorMessage = errorMessage
                }
                let completionRetry: (() -> ()) = { [weak self] in
                    self?.performViewCartRequest()
                }
                self.handleError(error, requestType: RequestType.viewCart, completionRetry: completionRetry, completionError: completionError)
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
                
                let completionError: ((String) -> ()) = { [weak self] errorMessage in
                    self?.errorMessage = errorMessage
                }
                let completionRetry: (() -> ()) = { [weak self] in
                    self?.performDeleteRequest(offerIds: offerIds)
                }
                self.handleError(error, requestType: RequestType.deleteFromCart, completionRetry: completionRetry, completionError: completionError)
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
        
        cell.onDelete = { [weak self] offer in
            
            guard let weakSelf = self else { return }
            weakSelf.performDeleteRequest(offerIds: [offer.id])
            
            if let filtered = weakSelf.cart?.offers.filter({ $0.id != offer.id }) {
                weakSelf.cart?.offers = filtered
            }
            let range = NSMakeRange(0, weakSelf.tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            weakSelf.tableView.reloadSections(sections as IndexSet, with: .automatic)
            if let items = weakSelf.cart?.offers.count, items < 1 {
                weakSelf.editButton.isEnabled = false
                weakSelf.editButton.isSelected = false
            }
            weakSelf.onDataChanged?()
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

extension MarketCartController: ErrorPresentable {}
