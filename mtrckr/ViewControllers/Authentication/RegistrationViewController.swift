//
//  RegistrationViewController.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit

class RegistrationViewController: MTViewController {

    @IBOutlet weak var emailTxtField: MTTextField!
    @IBOutlet weak var passwordTxtField: MTTextField!
    @IBOutlet weak var confirmPasswordTxtField: MTTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextfields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func createAccountBtnPressed(_ sender: MTButton) {
    
    }
    
    @IBAction func loginBtnPressed(_ sender: MTButton) {
    
    }
    
    // MARK: UI setup methods
    func setupTextfields() {
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
        confirmPasswordTxtField.delegate = self
    }
}
