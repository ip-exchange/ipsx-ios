//
//  ToastAlertView.swift
//  BPUIKit
//
//  Created by Calin Chitu on 2/24/17.
//  Copyright © 2017 BP Oil UK Limited. All rights reserved.
//

/*
How to use:
 
** Prequisites **
 - A table view or other full screen view to add this alert on top of it
 - An outlet to the table/other view's distance to top, to update animated when showing or hiding
 
** Add these properties to the view controller that supports the alert. **
 @IBOutlet weak var topConstraintOutlet: NSLayoutConstraint! {
    didSet {
        topConstraint = topConstraintOutlet
    }
 }
 var toast: ToastAlertView?
 var topConstraint: NSLayoutConstraint?

** Link the outlet with the storyboard constraint **
 
** Implement the ToastAlertViewPresentable protocol in the view controller that presents it **
 extension ImplementingViewController: ToastAlertViewPresentable {
 
    func createToastAlert(onTopOf parentUnderView: UIView, text: String) {
        if self.toast == nil, let toastView = ToastAlertView(parentUnderView: parentUnderView, parentUnderViewConstraint: self.topConstraint, alertText:text) {
            self.toast = toastView
            view.addSubview(toastView)
        }
    }
 }
 
** In viewDidLyoutSubviews, call **
 - createToastAlert(onTopOf: someView, text: "Some text")

** Display the toast with any of below **
 - toast?.showToastAlert() //will use the text passed at init
 - toast?.showToastAlert("Some text")
 - toast?.showToastAlert(autoHideAfter: 5)
 - toast?.showToastAlert("A text", autoHideAfter: 5)

** Hide the toast **
 - using the toast close button or
 - showing with dismiss timer or
 - toast?.hideToastAlert()
 
 */

import UIKit

public protocol ToastAlertViewPresentable {
    
    var toast: ToastAlertView? { get set }
    var topConstraint: NSLayoutConstraint? { get set }
    func createToastAlert(onTopOf parentUnderView: UIView, text: String)
}

public class ToastAlertView: UIView {
    
    @IBOutlet weak var alertTextLabel: UILabel!
    
    private weak var view: UIView!
    private weak var parent: UIView!
    private weak var underViewTopConstraint: NSLayoutConstraint!

    private var initialParentConstraint:  CGFloat!
    
    public init?(parentUnderView: UIView, parentUnderViewConstraint: NSLayoutConstraint, alertText: String) {
        
        let frame = CGRect(x: 0, y: parentUnderView.frame.origin.y - 50, width: UIScreen.main.bounds.width, height: 50)
        super.init(frame: frame)
        view = loadNib(withOwner: self)
        parent = parentUnderView
        underViewTopConstraint  = parentUnderViewConstraint
        initialParentConstraint = parentUnderViewConstraint.constant
        alertTextLabel.text = alertText
        self.alpha = 0
        addSubview(view)
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        view = loadNib(withOwner: self)
        addSubview(view)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        view = loadNib(withOwner: self)
        addSubview(view)
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        updateInfoToastUI(visible: false)
    }
    
    public func showToastAlert(_ text: String? = "", autoHideAfter: Double = 0.0) {
        updateInfoToastUI(visible: true, alertText: text)
        if autoHideAfter > 0.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + autoHideAfter) {
                self.updateInfoToastUI(visible: false)
            }
        }
    }
    
    public func hideToastAlert() {
        updateInfoToastUI(visible: false)
    }
    
    private func updateInfoToastUI(visible: Bool, alertText: String? = "") {
        
        if let text = alertText, text.count > 0 {
            alertTextLabel.text = text
            self.frame.size.height = max(50, alertTextLabel.requiredHeight() + 6)
        }

        superview?.layoutIfNeeded()
        underViewTopConstraint?.constant = (visible) ? initialParentConstraint + frame.size.height : initialParentConstraint
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.superview?.layoutIfNeeded()
            self.frame.origin.y = (visible) ? (self.parent?.frame.origin.y)! - self.frame.size.height : -self.frame.size.height
            self.alpha = (visible) ? 1.0 : 0.0
        }, completion: nil)
    }

    func loadNib(withOwner: UIView) -> UIView {
        
        let bundle = Bundle(for: self.classForCoder)
        let view = UIView.viewFromNib(withOwner: withOwner, bundle: bundle)
        
        view.frame = bounds
        
        return view
    }
}

extension UILabel {
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.height
    }
}
