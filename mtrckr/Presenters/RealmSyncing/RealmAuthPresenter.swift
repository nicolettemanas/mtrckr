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

protocol RealmAuthPresenterProtocol {
    func login(withEmail email: String, withPassword password: String)
    func register(withEmail email: String, withPassword password: String, withName name: String)
    func logout()
}

protocol RealmAuthPresenterOutput {
    func showFailedAuth(withAlert alert: UIAlertController?)
    func showSuccessfulLogin(ofUser user: RLMSyncUser)
    func showSuccessfulRegistration(ofUser user: RLMSyncUser)
    func showSuccesfulLogout()
}

class RealmAuthPresenter: RealmAuthPresenterProtocol, RealmAuthInteractorOutput {

    var interactor: RealmAuthInteractorProtocol
    var encrypter: EncryptionInteractorProtocol
    var output: RealmAuthPresenterOutput
    
    init(interactor: RealmAuthInteractorProtocol, encrypter: EncryptionInteractorProtocol, output: RealmAuthPresenterOutput) {
        self.interactor = interactor
        self.encrypter = encrypter
        self.output = output
    }
    
    // RealmAuthPresenterProtocol methods
    func login(withEmail email: String, withPassword password: String) {
        let encryptedPw = self.encrypter.encrypt(str: password)
        self.interactor.login(withEmail: email, withEncryptedPassword: encryptedPw)
    }
    
    func register(withEmail email: String, withPassword password: String, withName name: String) {
        let encryptedPw = self.encrypter.encrypt(str: password)
        self.interactor.register(withEmail: email, withEncryptedPassword: encryptedPw, withName: name)
    }
    
    func logout() {
        self.interactor.logout()
    }
    
    // MARK: RealmAuthInteractorOutput methods
    func didLogin(user: RLMSyncUser) {
        print(":: did login \(user)")
        self.output.showSuccessfulLogin(ofUser: user)
    }

    func didFailLogin(withError error: Error?) {
        print(":: did fail login \(String(describing: error))")
        self.output.showFailedAuth(withAlert: nil)
    }

    func didFailRegistration(withError error: Error?) {
        print(":: did fail registration \(String(describing: error))")
        self.output.showFailedAuth(withAlert: nil)
    }

    func didRegister(user: RLMSyncUser) {
        print(":: did register user \(String(describing: user.identity))")
        self.output.showSuccessfulRegistration(ofUser: user)
    }

    func didLogout() {
        print(":: did log out")
        self.output.showSuccesfulLogout()
    }
}
