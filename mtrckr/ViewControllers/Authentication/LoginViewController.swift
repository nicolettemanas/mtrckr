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
    
    @IBOutlet weak var loginScrollView: UIScrollView!
    
    weak var delegate: AuthViewControllerDelegate?
    var presenter: RealmAuthPresenterProtocol?
    
    override func viewDidLoad() {
        setupTextfields()
        scrollView = loginScrollView
        super.viewDidLoad()
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
        if emailTxtField.text == "" {
            emailTxtField.showError(errorMsg: "You can't leave this empty")
            return
        }
        
        if passwordTxtField.text == "" {
            passwordTxtField.showError(errorMsg: "You can't leave this empty")
            return
        }
        
        showLoadingView(withColor: MTColors.mainOrange)
        presenter?.login(withEmail: emailTxtField.text!, withPassword: passwordTxtField.text!, loginSyncOption: option)
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
    
    func showSuccessfulLogin(ofUser user: MTSyncUser) {
        hideLoadingView()
        delegate?.didDismiss()
        view.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField is MTTextField {
            let txt = textField.text as NSString?
            if let str = txt?.replacingCharacters(in: range, with: string) {
                if str.characters.count > 0 {
                    (textField as? MTTextField)?.hideError()
                }
            }
        }
        
        return true
    }

}
