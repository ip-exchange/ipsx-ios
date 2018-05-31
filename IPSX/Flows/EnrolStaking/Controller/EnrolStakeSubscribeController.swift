//
//  EnrolStakeSubscribeController.swift
//  IPSX
//
//  Created by Calin Chitu on 28/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

class EnrolStakeSubscribeController: UIViewController {

    @IBOutlet weak var joinStakingButton: RoundedButton!
    @IBOutlet weak var tableView: UITableView!
    //TODO (CC)
    @IBOutlet weak var loadingView: CustomLoadingView!
    
    var userInfo: UserInfo? { return UserManager.shared.userInfo }
    var ethAdresses: [EthAddress] = []
    
    //TODO (CC): logic to determine ethAddresses to delete from staking
    //TODO (CC): logic to determine ethAddresses to add for staking
    
    //TODO (CC)
    var errorMessage: String? {
        didSet {
            //self.toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func submitAction(_ sender: UIButton) {

        //TODO: make request for each eth
        //this is for testing
        let ethID = "92"
        enrollStaking(ethID: ethID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadValidAddresses()
    }
    
    private func loadValidAddresses() {
        if let addresses = UserManager.shared.ethAddresses {
            ethAdresses = addresses.filter { return  $0.validationState == .verified }
            tableView.reloadData()
        }
    }

    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func enrollStaking(ethID: String) {
        
        loadingView?.startAnimating()
        EnrollmentService().enrollStaking(ethID: ethID, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            
            switch result {
            case .success(let createdDate):
                
                print("TODO (CC)", ethID, createdDate)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showEnrollmentDetailsID", sender: nil)
                }
                
            case .failure(let error):
                self.handleError(error, requestType: .enrollStaking, completion: {
                    self.enrollStaking(ethID: ethID)
                })
            }
        })
    }
}

extension EnrolStakeSubscribeController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ethAdresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EthWalletCell.cellID, for: indexPath) as! EthWalletCell
        let ethAddress = ethAdresses[indexPath.item]
        cell.configure(address: ethAddress)
        return cell
    }
}

extension EnrolStakeSubscribeController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension EnrolStakeSubscribeController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {
        
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
