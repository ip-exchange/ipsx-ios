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
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var checkoutButton: RoundedButton!
    @IBOutlet weak var tableView: UITableView!
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
    var offersIdsToDelete: [Int] = []
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    fileprivate let cellID = "MarketCellID"
    private let checkoutSegueID = "CheckoutSegueID"
    private let addWalletSegueID = "AddWalletSegueID"
    var cart: Cart?
    
    private var hasWallet: Bool {
        return UserManager.shared.roles?.contains(UserRoles.Requester) ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.cornerRadius = 5
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: topSeparator, text: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performViewCartRequest()
        checkoutButton.isEnabled = hasWallet
        noWalletView.isHidden = hasWallet
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if errorMessage != nil { toast?.showToastAlert(self.errorMessage, autoHideAfter: 5) }
    }
    
    @IBAction func editAction(_ sender: UIButton) {
    
        let doneAction = sender.isSelected
        sender.isSelected = !sender.isSelected
        
        if doneAction && offersIdsToDelete.count > 0 {
            performDeleteRequest(offerIds: offersIdsToDelete)
        }
        tableView.reloadData()
    }
    
    @IBAction func checkout(_ sender: Any) {
        performSegue(withIdentifier: checkoutSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addWalletSegueID {
            let addWalletController = segue.destination as? WalletAddController
            addWalletController?.shouldPop = true
        }
    }
    
    func configureSummaryUI() {
        
        footerSubtotalLabel.text = cart?.ipsxSubtotal
        footerVATLabel.text      = cart?.ipsxVat
        footerTotalLabel.text    = cart?.ipsxTotal
        bottomTotalLabel.text    = cart?.ipsxTotal
    }
    
    func performViewCartRequest() {
        
        loadingView?.startAnimating()
        MarketplaceService().viewCart(completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(let cart):
                
                self.cart = cart as? Cart
                DispatchQueue.main.async {
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
                self.offersIdsToDelete = []
                self.performViewCartRequest()
                
            case .failure(let error):
                
                self.handleError(error, requestType: RequestType.deleteFromCart, completion: {
                    self.performDeleteRequest(offerIds: offerIds)
                })
            }
        })
    }
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
            
            self.offersIdsToDelete.append(offer.id)
            
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
        
        DispatchQueue.main.async {
            //self.performSegue(withIdentifier: self.marketItemID, sender: self)
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
