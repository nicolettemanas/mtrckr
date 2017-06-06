//
//  MTViewController.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit
import NVActivityIndicatorView

class MTViewController: UIViewController, UITextFieldDelegate {

    var loadingView: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    // MARK: - Activity indicator methods
    func showLoadingView() {
        if loadingView == nil {
            loadingView = NVActivityIndicatorView(frame: view.frame, type: .ballScale, color: .blue)
            view.addSubview(loadingView!)
        }
        loadingView?.startAnimating()
    }
    
    func hideLoadingView() {
        guard loadingView != nil else { return }
        loadingView?.stopAnimating()
    }

}
