//
//  AddWalletController.swift
//  IPSX
//
//  Created by Calin Chitu on 23/04/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit
import AVFoundation

class AddWalletController: UIViewController {

    @IBOutlet weak var screenTitleLabel: UILabel?
    @IBOutlet weak var sectionTitleLabel: UILabel?
    
    @IBOutlet weak var pasteAddrButton: UIButton!
    @IBOutlet weak var qrcodeButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet weak var loadingView: CustomLoadingView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var walletNameRichTextField: RichTextFieldView!
    @IBOutlet weak var ethAddresRichTextField: RichTextFieldView!
    @IBOutlet weak var bottomContinueConstraint: NSLayoutConstraint?
    @IBOutlet weak var loginAnotherAccButton: RoundedButton!
    @IBOutlet weak var doneButton: UIButton?
    @IBOutlet weak var saveButton: UIButton?
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?
    var ethereumAddress: EthAddress?
    var continueBottomDist: CGFloat = 0.0
    var shouldPop = false
    
    private var fieldsStateDic: [String : Bool] = ["walletName" : true, "ethAddress" : false]
    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    @IBAction func loginAnotherAccountAction(_ sender: UIButton) {
        loginAnotherAccount()
    }
    
    func loginAnotherAccount() {
        
        UserManager.shared.logout()
        self.performSegue(withIdentifier: "UnwindAndShowLandingID", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueBottomDist = bottomContinueConstraint?.constant ?? 0
        observreFieldsState()
        if let address = ethereumAddress {
            fieldsStateDic = ["walletName" : true, "ethAddress" : true]
            walletNameRichTextField.contentTextField?.text = address.alias
            ethAddresRichTextField.contentTextField?.text = address.address
            screenTitleLabel?.text = "Edit ETH Address text".localized
            sectionTitleLabel?.text = "Edit your ETH address text".localized
            ethAddresRichTextField.contentTextField?.isEnabled = false
            qrcodeButton.isHidden = true
            pasteAddrButton.isHidden = true
        } else {
            screenTitleLabel?.text = "Add ETH Address text".localized
            sectionTitleLabel?.text = "Add your ETH address text".localized
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    @objc func appWillEnterForeground() {
        updateReachabilityInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        updateReachabilityInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView?.createParticlesAnimation()
        setupTextViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "")
    }
    
    @objc public func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            let reachability = note.object as! Reachability
            
            if !reachability.isReachable {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            } else {
                self.toast?.hideToastAlert()
            }
        }
    }

    func updateReachabilityInfo() {
        DispatchQueue.main.async {
            if ReachabilityManager.shared.isReachable() {
                self.toast?.hideToastAlert()
            } else {
                self.toast?.showToastAlert("No internet connection".localized, dismissable: false)
            }
        }
    }

    private func setupTextViews() {
        walletNameRichTextField.nextResponderField = ethAddresRichTextField.contentTextField
        walletNameRichTextField.validationRegex    = RichTextFieldView.validName
        ethAddresRichTextField.validationRegex     = RichTextFieldView.validEthAddress
    }
    
    private func observreFieldsState() {
        walletNameRichTextField.onFieldStateChange = { state in
            let curentNameText = self.walletNameRichTextField.contentTextField?.text?.trimLeadingAndTrailingSpaces() ?? ""
            self.fieldsStateDic["walletName"] = state
            self.doneButton?.isEnabled = !self.fieldsStateDic.values.contains(false) && curentNameText != self.ethereumAddress?.alias && curentNameText.count > 0
            self.saveButton?.isEnabled = !self.fieldsStateDic.values.contains(false) && curentNameText != self.ethereumAddress?.alias && curentNameText.count > 0
        }
        ethAddresRichTextField.onFieldStateChange = { state in
            let curentNameText = self.walletNameRichTextField.contentTextField?.text ?? ""
            self.fieldsStateDic["ethAddress"] = state
            self.doneButton?.isEnabled = !self.fieldsStateDic.values.contains(false) && self.ethAddresRichTextField.contentTextField?.text != self.ethereumAddress?.address && curentNameText.count > 0
            self.saveButton?.isEnabled = !self.fieldsStateDic.values.contains(false) && self.ethAddresRichTextField.contentTextField?.text != self.ethereumAddress?.address && curentNameText.count > 0
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        
        guard ethereumAddress != nil else {
            shouldPop = true
            doneAction(sender)
            return
        }
        let alias = walletNameRichTextField.contentTextField?.text?.trimLeadingAndTrailingSpaces() ?? ""
        let address = ethAddresRichTextField.contentTextField?.text ?? ""
        let ethID = ethereumAddress?.ethID ?? 0
        
        updateETHaddress(alias: alias, address: address, ethID: ethID)
    }
    
    func updateETHaddress(alias: String, address: String, ethID: Int) {
    
        loadingView?.startAnimating()
        UserInfoService().updateETHaddress(requestType: .updateEthAddress, ethID: ethID, alias: alias, address: address, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(_):
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .failure(let error):

                self.handleError(error, requestType: .updateEthAddress, completion: {
                    self.updateETHaddress(alias: alias, address: address, ethID: ethID)
                })
            }
        })
    }
    
    @IBAction func unwindToRegCredentials(segue:UIStoryboardSegue) { }
    
    
    @IBAction func doneAction(_ sender: UIButton) {
        addEthAdress()
    }
    
    func addEthAdress() {
        
        let alias = walletNameRichTextField.contentTextField?.text?.trimLeadingAndTrailingSpaces() ?? ""
        let address = ethAddresRichTextField.contentTextField?.text ?? ""
        
        loadingView?.startAnimating()
        RegisterService().addEthAdress(address: address, alias: alias, completionHandler: { result in
            
            self.loadingView?.stopAnimating()
            switch result {
                
            case .success(let ethAddress):
                
                DispatchQueue.main.async {
                    
                    if let ethAddress = ethAddress as? EthAddress {
                        UserManager.shared.ethAddresses = [ethAddress]
                    }
                    if self.shouldPop {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.performSegue(withIdentifier: "showCongratsSegueID", sender: nil)
                    }
                }
                
            case .failure(let error):
                self.handleError(error, requestType: .addEthAddress, completion: {
                    self.addEthAdress()
                })
            }
        })
    }
    
    @IBAction func qrCodeAction(_ sender: Any) {
        let scannerController = QRScannViewController()
        scannerController.onCodeFound = { code in
            self.ethAddresRichTextField.contentTextField?.text = code
            self.ethAddresRichTextField.refreshStatus()
        }
        self.present(scannerController, animated: true) {
        }
    }
    
    @IBAction func pasteAction(_ sender: Any) {
        if let clipboardText = UIPasteboard.general.string {
            ethAddresRichTextField.contentTextField?.text = clipboardText
            ethAddresRichTextField.refreshStatus()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard let keyboardFrame = notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        bottomContinueConstraint?.constant = keyboardHeight + 10
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        bottomContinueConstraint?.constant = continueBottomDist
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

}

extension AddWalletController: ToastAlertViewPresentable {
    
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint!, alertText:text) {
            self.toast = toastView
            view.insertSubview(toastView, belowSubview: topBarView)
        }
    }
}

class QRScannViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var onCodeFound: ((_ newCode: String)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func setup() {
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    private func failed() {
        let ac = UIAlertController(title: "Scanning not supported message".localized, message: "No Cammera Message".localized, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK".localized, style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    private func found(code: String) {
        onCodeFound?(code)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true)
    }
}

class FirstWalletDoneController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
    }
}

extension AddWalletController: ErrorPresentable {
    
    func handleError(_ error: Error, requestType: IPRequestType, completion:(() -> ())? = nil) {

        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                self.errorMessage = "Generic Error Message".localized
                
            }, successHandler: {
                completion?()
            })
        default:
            
            switch requestType {
                
            case .updateEthAddress, .addEthAddress:
                if let customErr = error as? CustomError, case .alreadyExists = customErr {
                    self.errorMessage = "ETH Address Already Used Error Message".localized
                }
                else {
                    self.errorMessage = "Generic Error Message".localized
                }
            default:
                self.errorMessage = "Generic Error Message".localized
            }
        }
    }
}
