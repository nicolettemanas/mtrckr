//
//  Login.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit
import RealmSwift
import Realm

class LoginViewController: MTViewController, RealmAuthPresenterOutput {

    @IBOutlet weak var emailTxtField: MTTextField!
    @IBOutlet weak var passwordTxtField: MTTextField!
    
    var presenter: RealmAuthPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextfields()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtnPressed(_ sender: MTButton) {
    
    }
    
    @IBAction func createBtnPressed(_ sender: MTButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissBtnPressed(_ sender: MTButton) {
        view.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: UI setup methods
    func setupTextfields() {
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
    }
    
    // MARK: - RealmAuthPresenterOutput methods
    func showFailedAuth(withAlert alert: UIAlertController?) {
        
    }
    
    func showSuccesfulLogout() {
        
    }
    
    func showSuccessfulLogin(ofUser user: RLMSyncUser) {
        
    }
    
    func showSuccessfulRegistration(ofUser user: RLMSyncUser) {
        
    }
}
