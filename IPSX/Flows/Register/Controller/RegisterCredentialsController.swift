//
//  RegCredentialsController.swift
//  IPSXSandbox
//
//  Created by Calin Chitu on 17/04/2018.
//  Copyright © 2018 Calin Chitu. All rights reserved.
//

import UIKit

@IBDesignable
class RegisterCredentialsController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var emailRichTextView: RichTextFieldView!
    @IBOutlet weak var passRichTextField: RichTextFieldView!
    @IBOutlet weak var passCheckRichTextField: RichTextFieldView!
    @IBOutlet weak var bottomContinueConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButton: RoundedButton!
    
    var continueBottomDist: CGFloat = 0.0
    private var fieldsStateDic: [String : Bool] = ["email" : false, "pass1" : false, "pass2" : false]
    var userCredentials: [String: String] = ["email": "", "pass": ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueBottomDist = bottomContinueConstraint.constant
        observreFieldsState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        backgroundImageView.removeParticlesAnimation()
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundImageView.createParticlesAnimation()
        setupTextViews()
    }
    
    private func setupTextViews() {
        emailRichTextView.validationRegex       = RichTextFieldView.validEmailRegex
        emailRichTextView.nextResponderField    = passRichTextField.contentTextField
        passRichTextField.validationRegex       = RichTextFieldView.validPasswordRegex
        passRichTextField.nextResponderField    = passCheckRichTextField.contentTextField
        passCheckRichTextField.validationRegex  = RichTextFieldView.validPasswordRegex
        passCheckRichTextField.mathingTextField = passRichTextField.contentTextField
    }
    
    private func observreFieldsState() {
        emailRichTextView.onFieldStateChange = { state in
            self.fieldsStateDic["email"] = state
            self.continueButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
        passRichTextField.onFieldStateChange = { state in
            self.fieldsStateDic["pass1"] = state
            self.continueButton.isEnabled = !self.fieldsStateDic.values.contains(false)
            self.passCheckRichTextField.contentTextField?.text = ""
        }
        passCheckRichTextField.onFieldStateChange = { state in
            self.fieldsStateDic["pass2"] = state
            self.continueButton.isEnabled = !self.fieldsStateDic.values.contains(false)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToRegCredentials(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showRegistrationTermsSegueID" {
            if let email = emailRichTextView.contentTextField?.text, let password = passRichTextField.contentTextField?.text {
                let nextScreen = segue.destination as? RegisterTermsController
                nextScreen?.userCredentials = ["email": email,
                                               "pass" : password]
            }
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
        
        bottomContinueConstraint.constant = keyboardHeight + 10
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        bottomContinueConstraint.constant = continueBottomDist
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
}

