//
//  RealmAuthPresenter.swift
//  mtrckr
//
//  Created by User on 5/16/17.
//
//

import UIKit
import Realm
import RealmSwift

/// Options available during logging in
///
/// - `.useRemote`: Discards offline data and only use synced data
/// - `.append`: Appends values of offline data to synced data
enum LoginSyncOption {
    case useRemote, append
}

/// :nodoc:
protocol RealmAuthPresenterProtocol {
    var output: RealmAuthPresenterOutput? { get set }
    func login(withEmail email: String, withPassword password: String, loginSyncOption option: LoginSyncOption)
    func register(withEmail email: String, withPassword password: String, withName name: String)
    func logout()
}

/// Collection of properties and methods that `RealmAuthPresenter` gives its `output`.
/// Must be conformed to when used `RealmAuthPresenter` as an event handler
@objc protocol RealmAuthPresenterOutput {
    // MARK: - Authentication
    /// Passes a UIAlertController when an authentication is failed (Login and Sign up)
    ///
    /// - Parameter alert: The UIAlertController to be displayed
    @objc optional func showFailedAuth(withAlert alert: UIAlertController?)
    
    /// Triggered when a user has successfully logged in
    ///
    /// - Parameter user: The `MTSyncUser` logged in
    @objc optional func showSuccessfulLogin(ofUser user: MTSyncUser)
    
    /// Triggered when a user has successfully registered
    ///
    /// - Parameter user: The newly registered `MTSyncUser`
    @objc optional func showSuccessfulRegistration(ofUser user: MTSyncUser)
    
    /// Triggered when a user has logged out
    @objc optional func showSuccesfulLogout()
}

/// The event handler for authentication ViewControllers
class RealmAuthPresenter: RealmAuthPresenterProtocol, RealmRegInteractorOutput,
                            RealmLoginInteractorOutput, RealmLogoutInteractorOutput {

    // MARK: - Properties
    
    /// The interactor responsible for registration purposes
    var regInteractor: RealmRegInteractorProtocol?
    
    /// The interactor responsible for login purposes
    var loginInteractor: RealmLoginInteractorProtocol?
    
    /// The interactor responsible for logout purposes
    var logoutInteractor: RealmLogoutInteractorProtocol?
    
    /// The interactor responsible for encryption purposes
    var encrypter: EncryptionInteractorProtocol?
    
    /// The output of the presenter
    var output: RealmAuthPresenterOutput?
    
    // MARK: - Initializers
    /// Creates a RealmAuthPresenter with given interactors
    ///
    /// - Parameters:
    ///   - regInteractor: The interactor to use in registration
    ///   - loginInteractor: The interactor to use in logging in
    ///   - logoutInteractor: The interactor to use in logging out
    ///   - encrypter: The interactor to use when encrypting data
    ///   - output: The delegate output of RealmAuthPresenter
    init(regInteractor: RealmRegInteractorProtocol?, loginInteractor: RealmLoginInteractorProtocol?,
         logoutInteractor: RealmLogoutInteractorProtocol?, encrypter: EncryptionInteractorProtocol?,
         output: RealmAuthPresenterOutput?) {
        
        self.regInteractor = regInteractor
        self.loginInteractor = loginInteractor
        self.logoutInteractor = logoutInteractor
        self.encrypter = encrypter
        self.output = output
    }
    
    // MARK: - Event handlers
    /// Event handler for loggin in; encrypts data to be passed to the interactor
    ///
    /// - Parameters:
    ///   - email: The email credential of the user to login
    ///   - password: The password credential of the user to login
    ///   - option: The login option, see `LoginSyncOption`
    func login(withEmail email: String, withPassword password: String, loginSyncOption option: LoginSyncOption) {
        assert(loginInteractor != nil)
        assert(encrypter != nil)
            
        if let encryptedPw = self.encrypter?.encrypt(str: password) {
            self.loginInteractor?.login(withEmail: email, withEncryptedPassword: encryptedPw, loginOption: option)
        }
    }
    
    /// Event handler for creating an account; encrypts data to be passed to the interactor
    ///
    /// - Parameters:
    ///   - email: The email credential of the user
    ///   - password: The password credential of the user
    ///   - name: The name of the user
    func register(withEmail email: String, withPassword password: String, withName name: String) {
        assert(regInteractor != nil)
        assert(encrypter != nil)
        if let encryptedPw = self.encrypter?.encrypt(str: password) {
            self.regInteractor?.register(withEmail: email, withEncryptedPassword: encryptedPw, withName: name)
        }
    }
    
    /// Event handler for logging out
    func logout() {
        assert(logoutInteractor != nil)
        self.logoutInteractor?.logout()
    }
    
    // MARK: - Output methods
    /// Fires when a user has successfuly logded in
    ///
    /// - Parameter user: The `MTSyncUser` logged in
    func didLogin(user: MTSyncUser) {
        DispatchQueue.main.async {
            self.output?.showSuccessfulLogin?(ofUser: user)
        }
    }
    
    /// Fires when an error encountered upon login
    ///
    /// - Parameter error: The error encountered upon login
    func didFailLogin(withError error: Error?) {
        print(":: did fail login \(String(describing: error))")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Oops! Something went wrong.", message: error?.localizedDescription, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.output?.showFailedAuth?(withAlert: alert)
        }
    }

    /// Fires when there is an error encountered during registration
    ///
    /// - Parameter error: The Error encountered during registration
    func didFailRegistration(withError error: Error?) {
        print(":: did fail registration \(String(describing: error))")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Oops! Something went wrong.", message: error?.localizedDescription, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.output?.showFailedAuth?(withAlert: alert)
        }
    }

    /// Fires when a user has successfully registered
    ///
    /// - Parameter user: The newly registered `MTSyncUser`
    func didRegister(user: MTSyncUser) {
        print(":: did register user \(String(describing: user.identity))")
        DispatchQueue.main.async {
            self.output?.showSuccessfulRegistration?(ofUser: user)
        }
    }

    /// Fires when a user has logged out
    func didLogout() {
        print(":: did log out")
        DispatchQueue.main.async {
            self.output?.showSuccesfulLogout?()
        }
    }
}
