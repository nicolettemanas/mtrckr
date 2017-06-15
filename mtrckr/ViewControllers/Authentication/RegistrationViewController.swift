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
import SkyFloatingLabelTextField

class RegistrationViewController: MTViewController, RealmAuthPresenterOutput {
    
    @IBOutlet weak var regEmail: MTTextField!
    @IBOutlet weak var regPw: MTTextField!
    @IBOutlet weak var regConfirmPw: MTTextField!
    
    @IBOutlet weak var regScrollView: UIScrollView!
    
    weak var delegate: AuthViewControllerDelegate?
    var presenter: RealmAuthPresenterProtocol?
    
    override func viewDidLoad() {
        setupTextfields()
        scrollView = regScrollView
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: LoginView actions
    @IBAction func createAccountBtnPressed(_ sender: MTButton) {
        if isValid() {
            showLoadingView(withColor: MTColors.mainBlue)
            presenter?.register(withEmail: regEmail.text!, withPassword: regPw.text!, withName: regConfirmPw.text!)
        }
    }
    
    @IBAction func loginBtnPressed(_ sender: MTButton) {
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        else {
            fatalError("Cannot find view controller with identifier LoginViewController")
        }
        
        let authConfig = RealmAuthConfig()
        let authEncryption = EncryptionInteractor()
        let loginInteractor = RealmLoginInteractor(config: authConfig)
        let loginPresenter = RealmAuthPresenter(regInteractor: nil,
                                               loginInteractor: loginInteractor,
                                               logoutInteractor: nil,
                                               encrypter: authEncryption,
                                               output: loginVC)
        loginInteractor.output = loginPresenter
        loginVC.delegate = self.delegate
        loginVC.presenter = loginPresenter
        
        present(loginVC, animated: true)
    }
    
    @IBAction func dismissBtnPressed(_ sender: MTButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UI setup methods
    func setupTextfields() {
        regEmail.delegate = self
        regPw.delegate = self
        regConfirmPw.delegate = self
    }
    
    // MARK: - Validation methods
    func isValid() -> Bool {
        guard regEmail.text != nil,
            let pw = regPw.text,
            let cpw = regConfirmPw.text else {
            return false
        }
        
        return pw.characters.count >= 6 && (pw == cpw)
    }
    
    // MARK: - RealmAuthPresenterOutput methods
    func showFailedAuth(withAlert alert: UIAlertController?) {
        hideLoadingView()
        if alert != nil {
            present(alert!, animated: true, completion: nil)
        }
    }
    
    func showSuccessfulRegistration(ofUser user: RLMSyncUser) {
        hideLoadingView()
        delegate?.didDismiss()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let txt = textField.text as NSString?
        if let text = txt?.replacingCharacters(in: range, with: string) {
            guard let mttextField = textField as? MTTextField else {
                return true
            }
            
            if textField == regEmail {
                let emailRegEx = "[A-Z0-9a-z.dd_%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                if emailTest.evaluate(with: text) {
                    mttextField.hideError()
                } else {
                    mttextField.showError(errorMsg: "Invalid email")
                }
            } else if textField == regPw || textField == regConfirmPw {
                if text.characters.count >= 6 {
                    
                    let isPw = textField == regPw
                    let pwMatches = text == (isPw ? regConfirmPw.text : regPw.text)
                    
                    if pwMatches {
                        regPw.hideError()
                        regConfirmPw.hideError()
                    } else {
                        regPw.showError(errorMsg: "Passwords do not match")
                        regConfirmPw.showError(errorMsg: "Passwords do not match")
                    }
                } else {
                    mttextField.showError(errorMsg: "Password must be at least 6 characters long")
                }
            }
        }
        
        return true
    }
}
