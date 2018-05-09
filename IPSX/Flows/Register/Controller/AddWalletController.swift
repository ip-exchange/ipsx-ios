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

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var walletNameRichTextField: RichTextFieldView!
    @IBOutlet weak var ethAddresRichTextField: RichTextFieldView!
    @IBOutlet weak var bottomContinueConstraint: NSLayoutConstraint?
    @IBOutlet weak var loginAnotherAccButton: RoundedButton!
    @IBOutlet weak var doneButton: UIButton?
    @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
        didSet {
            topConstraint = topConstraintOutlet
        }
    }
    var toast: ToastAlertView?
    var topConstraint: NSLayoutConstraint?

    //TODO (CVI): do we need validation for wallet name ?
    private var fieldsStateDic: [String : Bool] = ["walletName" : true, "ethAddress" : false]
    
    var errorMessage: String? {
        didSet {
            toast?.showToastAlert(self.errorMessage, autoHideAfter: 5)
        }
    }
    
    var continueBottomDist: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueBottomDist = bottomContinueConstraint?.constant ?? 0
        observreFieldsState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTextViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createToastAlert(onTopOf: separatorView, text: "Invalid Credentials")
    }
    
    private func setupTextViews() {
        walletNameRichTextField.nextResponderField    = ethAddresRichTextField.contentTextField
        ethAddresRichTextField.validationRegex        = RichTextFieldView.validEthAddress
    }
    
    private func observreFieldsState() {
        walletNameRichTextField.onFieldStateChange = { state in
            self.fieldsStateDic["walletName"] = state
            self.doneButton?.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
        ethAddresRichTextField.onFieldStateChange = { state in
            self.fieldsStateDic["ethAddress"] = state
            self.doneButton?.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
    }
    
    @IBAction func unwindToRegCredentials(segue:UIStoryboardSegue) { }
    
    
    @IBAction func doneAction(_ sender: UIButton) {
        
        let alias = walletNameRichTextField.contentTextField?.text ?? ""
        let address = ethAddresRichTextField.contentTextField?.text ?? ""
        
        RegisterService().addEthAdress(address: address, alias: alias, completionHandler: { result in
            
            switch result {
                
            case .success(_):
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showCongratsSegueID", sender: nil)
                }
                
            case .failure(let error):
                
                guard let customError = error as? CustomError else {
                    self.errorMessage = "Generic Error Message".localized
                    return
                }
                switch customError {
                case .ethAddressAlreadyUsed:
                    self.errorMessage = "ETH Address Already Used Error Message".localized
                    
                default:
                    self.errorMessage = "Generic Error Message".localized
                    break
                }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showLoginSegueID" {
            
            //TODO (CVI): perform logout request
            UserManager.shared.removeUserDetails()
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
            view.addSubview(toastView)
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
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
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
