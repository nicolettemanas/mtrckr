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

enum LoginSyncOption {
    case useRemote, append
}

protocol RealmAuthPresenterProtocol {
    func login(withEmail email: String, withPassword password: String, loginSyncOption option: LoginSyncOption)
    func register(withEmail email: String, withPassword password: String, withName name: String)
    func logout()
}

@objc protocol RealmAuthPresenterOutput {
    @objc optional func showFailedAuth(withAlert alert: UIAlertController?)
    @objc optional func showSuccessfulLogin(ofUser user: MTSyncUser)
    @objc optional func showSuccessfulRegistration(ofUser user: MTSyncUser)
    @objc optional func showSuccesfulLogout()
}

class RealmAuthPresenter: RealmAuthPresenterProtocol, RealmRegInteractorOutput,
                            RealmLoginInteractorOutput, RealmLogoutInteractorOutput {

    var regInteractor: RealmRegInteractorProtocol?
    var loginInteractor: RealmLoginInteractorProtocol?
    var logoutInteractor: RealmLogoutInteractorProtocol?
    var encrypter: EncryptionInteractorProtocol?
    var output: RealmAuthPresenterOutput?
    
    init(regInteractor: RealmRegInteractorProtocol?, loginInteractor: RealmLoginInteractorProtocol?,
         logoutInteractor: RealmLogoutInteractorProtocol?, encrypter: EncryptionInteractorProtocol?,
         output: RealmAuthPresenterOutput?) {
        
        self.regInteractor = regInteractor
        self.loginInteractor = loginInteractor
        self.logoutInteractor = logoutInteractor
        self.encrypter = encrypter
        self.output = output
    }
    
    // MARK: - RealmAuthPresenterProtocol methods
    func login(withEmail email: String, withPassword password: String, loginSyncOption option: LoginSyncOption) {
        assert(loginInteractor != nil)
        assert(encrypter != nil)
            
        if let encryptedPw = self.encrypter?.encrypt(str: password) {
            self.loginInteractor?.login(withEmail: email, withEncryptedPassword: encryptedPw, loginOption: option)
        }
    }
    
    func register(withEmail email: String, withPassword password: String, withName name: String) {
        assert(regInteractor != nil)
        assert(encrypter != nil)
        if let encryptedPw = self.encrypter?.encrypt(str: password) {
            self.regInteractor?.register(withEmail: email, withEncryptedPassword: encryptedPw, withName: name)
        }
    }
    
    func logout() {
        assert(logoutInteractor != nil)
        self.logoutInteractor?.logout()
    }
    
    // MARK: - RealmLoginInteractorOutput methods
    func didLogin(user: MTSyncUser) {
        print(":: did login \(user)")
        DispatchQueue.main.async {
            self.output?.showSuccessfulLogin?(ofUser: user)
        }
    }

    func didFailLogin(withError error: Error?) {
        print(":: did fail login \(String(describing: error))")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Oops! Something went wrong.", message: error?.localizedDescription, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.output?.showFailedAuth?(withAlert: alert)
        }
    }

    // MARK: - RealmRegInteractorOutput methods
    func didFailRegistration(withError error: Error?) {
        print(":: did fail registration \(String(describing: error))")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Oops! Something went wrong.", message: error?.localizedDescription, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            self.output?.showFailedAuth?(withAlert: alert)
        }
    }

    func didRegister(user: MTSyncUser) {
        print(":: did register user \(String(describing: user.identity))")
        DispatchQueue.main.async {
            self.output?.showSuccessfulRegistration?(ofUser: user)
        }
    }

    // MARK: RealmLoginInteractorOutput methods
    func didLogout() {
        print(":: did log out")
        DispatchQueue.main.async {
            self.output?.showSuccesfulLogout?()
        }
    }
}
