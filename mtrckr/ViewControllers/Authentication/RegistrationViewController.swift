//
//  AuthenticationViewController.swift
//  mtrckr
//
//  Created by User on 6/2/17.
//
//

import UIKit
import Hero
import Realm
import RealmSwift

class RegistrationViewController: MTViewController, RealmAuthPresenterOutput {
    
    @IBOutlet weak var regEmail: MTTextField!
    @IBOutlet weak var regPw: MTTextField!
    @IBOutlet weak var regConfirmPw: MTTextField!
    
    var presenter: RealmAuthPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextfields()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: LoginView actions
    @IBAction func createAccountBtnPressed(_ sender: MTButton) {
        
    }
    
    @IBAction func loginBtnPressed(_ sender: MTButton) {
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else {
            fatalError("Cannot find view controller with identifier LoginViewController")
        }
        
        present(loginVC, animated: true)
    }
    
    @IBAction func dismissBtnPressed(_ sender: MTButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UI setup methods
    func setupTextfields() {
        regEmail.delegate = self
        regPw.delegate = self
        regConfirmPw.delegate = self
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
