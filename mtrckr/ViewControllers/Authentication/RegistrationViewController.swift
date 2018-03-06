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
    @IBAction func createAccountBtnPressed(_ sender: MTButton?) {
        if isValid() {
            showLoadingView(withColor: MTColors.mainBlue)
            presenter?.register(withEmail: regEmail.text!, withPassword: regPw.text!, withName: regEmail.text!)
        }
    }

    @IBAction func loginBtnPressed(_ sender: MTButton) {
        guard let loginVC = storyboard?
            .instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        else {
            fatalError("Cannot find view controller with identifier LoginViewController")
        }

        let authConfig = RealmAuthConfig()
        let authEncryption = EncryptionInteractor()
        let loginInteractor = RealmLoginInteractor(with: authConfig)
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

    @IBAction func dismissBtnPressed(_ sender: MTButton?) {
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

        return (pw.count >= 6) &&
                (pw == cpw) &&
                isValidEmail(email: regEmail.text!)
    }

    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z.dd_%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    // MARK: - RealmAuthPresenterOutput methods
    func showFailedAuth(withAlert alert: UIAlertController?) {
        hideLoadingView()
        if alert != nil {
            present(alert!, animated: true, completion: nil)
        }
    }

    func showSuccessfulRegistration(ofUser user: MTSyncUser) {
        hideLoadingView()
        delegate?.didDismiss()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITextFieldDelegate methods
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let txt = textField.text as NSString?
        if let text = txt?.replacingCharacters(in: range, with: string) {
            guard let mttextField = textField as? MTTextField else {
                return true
            }

            if textField == regEmail {
                if isValidEmail(email: text) {
                    mttextField.hideError()
                } else {
                    mttextField.showError(errorMsg:
                        NSLocalizedString("Invalid email",
                                          comment: "Text indicating that the email provided is invalid"))
                }
            } else if textField == regPw || textField == regConfirmPw {
                if text.count >= 6 {

                    let isPw = textField == regPw
                    let pwMatches = text == (isPw ? regConfirmPw.text : regPw.text)

                    if pwMatches {
                        regPw.hideError()
                        regConfirmPw.hideError()
                    } else {
                        regPw.showError(errorMsg:
                            NSLocalizedString("Passwords do not match",
                                              comment: "Text indicating that inputted passwords do not match "))
                        regConfirmPw.showError(errorMsg:
                            NSLocalizedString("Passwords do not match",
                                              comment: "Text indicating that inputted passwords do not match "))
                    }
                } else {
                    mttextField.showError(errorMsg:
                        NSLocalizedString("Password must be at least 6 characters long",
                                          comment: "Error message displayed when the password typed" +
                            "is shorter than the minimum 6 characters"))
                }
            }
        }

        return true
    }
}
