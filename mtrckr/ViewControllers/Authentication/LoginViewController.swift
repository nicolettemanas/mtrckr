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
    
    weak var delegate: AuthViewControllerDelegate?
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
        displayLoginOptions()
    }
    
    @IBAction func createBtnPressed(_ sender: MTButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissBtnPressed(_ sender: MTButton) {
        view.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Login methods
    func displayLoginOptions() {
        let loginOptions = UIAlertController(title: nil,
                                             message: "Looks like you have some unsaved data. Do you want to add these to your account?",
                                             preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            loginOptions.dismiss(animated: true, completion: nil)
        }
        
        let OKAction = UIAlertAction(title: "Yes, please", style: .default) { _ in
            self.loginWithOption(option: .append)
        }
        
        let destroyAction = UIAlertAction(title: "No, delete them", style: .destructive) { _ in
            self.loginWithOption(option: .useRemote)
        }
        
        loginOptions.addAction(cancelAction)
        loginOptions.addAction(OKAction)
        loginOptions.addAction(destroyAction)
        
        present(loginOptions, animated: true, completion: nil)
    }
    
    func loginWithOption(option: LoginSyncOption) {
        guard let email = emailTxtField.text,
            let pw = passwordTxtField.text else {
                if emailTxtField.text == nil {
                    emailTxtField.errorMessage = "You can't leave this empty"
                }
                if passwordTxtField.text == nil {
                    passwordTxtField.errorMessage = "You can't leave this empty"
                }
                return
        }
        showLoadingView()
        presenter?.login(withEmail: email, withPassword: pw, loginSyncOption: option)
    }
    
    // MARK: UI setup methods
    func setupTextfields() {
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
    }
    
    // MARK: - RealmAuthPresenterOutput methods
    func showFailedAuth(withAlert alert: UIAlertController?) {
        hideLoadingView()
        if alert != nil {
            present(alert!, animated: true, completion: nil)
        }
    }
    
    func showSuccessfulLogin(ofUser user: RLMSyncUser) {
        hideLoadingView()
        delegate?.didDismiss()
        view.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let txtField = textField as? MTTextField {
            let txt = textField.text as NSString?
            if let str = txt?.replacingCharacters(in: range, with: string) {
                if str.characters.count > 0 {
                    txtField.errorMessage = ""
                }
            }
        }
        
        return true
    }

}
