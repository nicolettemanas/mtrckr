//
//  Login.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit

class LoginViewController: MTViewController {

    @IBOutlet weak var emailTxtField: MTTextField!
    @IBOutlet weak var passwordTxtField: MTTextField!
    
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
    
    }
    
    // MARK: UI setup methods
    func setupTextfields() {
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
    }
}
