//
//  MTViewController.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit
import NVActivityIndicatorView

/// The base class for UIViewController which handles most of general controller methods
class MTViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    
    /// The view displayed when showLoadingView is called
    var loadingView: NVActivityIndicatorView?
    
    var scrollView: UIScrollView? { didSet {
            scrollView?.keyboardDismissMode = .interactive
        }
    }
    
    deinit {
        print("[VIEW CONTROLLER] Deallocating \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MTColors.lightBg
        listenToKeyboard()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back-tab")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back-tab")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Methods
    
    /// Shows and animates the loading view
    ///
    /// - Parameter color: UIColor of the loading view to be displayed
    func showLoadingView(withColor color: UIColor) {
        if loadingView == nil {
            loadingView = NVActivityIndicatorView(frame: view.frame, type: .ballScale, color: color)
            view.addSubview(loadingView!)
        }
        loadingView?.startAnimating()
    }
    
    /// Hides the loading view of the viewcontroller
    func hideLoadingView() {
        guard loadingView != nil else { return }
        loadingView?.stopAnimating()
    }
    
    // MARK: - Keyboard & Scrollview methods
    private func listenToKeyboard() {
        if self.scrollView != nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardWillShow),
                                                   name:NSNotification.Name.UIKeyboardWillShow,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardWillHide),
                                                   name:NSNotification.Name.UIKeyboardWillHide,
                                                   object: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.scrollView != nil {
            var userInfo = notification.userInfo!
            guard let keyboardFrameValue: NSValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue
            else {
                return
            }
            
            var keyboardFrame: CGRect = keyboardFrameValue.cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            var contentInset: UIEdgeInsets = self.scrollView!.contentInset
            contentInset.bottom = keyboardFrame.size.height
            self.scrollView?.contentInset = contentInset
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.scrollView != nil {
            let contentInset: UIEdgeInsets = UIEdgeInsets.zero
            self.scrollView!.contentInset = contentInset
        }
    }

}
