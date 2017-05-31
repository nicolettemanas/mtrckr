//
//  RealmAuthInteractor.swift
//  mtrckr
//
//  Created by User on 5/16/17.
//
//

import UIKit
import Realm
import RealmSwift

protocol RealmAuthInteractorOutput {
    func didFailLogin(withError error: Error?)
    func didLogin(user: RLMSyncUser)
    func didFailRegistration(withError error: Error?)
    func didRegister(user: RLMSyncUser)
    func didLogout()
}

protocol RealmAuthInteractorProtocol {
    func login(withEmail email: String, withEncryptedPassword password: String, loginOption option: LoginSyncOption)
    func register(withEmail email: String, withEncryptedPassword password: String, withName name: String)
    func logout()
}
class RealmAuthInteractor: RealmAuthInteractorProtocol {

    var config: AuthConfigProtocol
    var output: RealmAuthInteractorOutput?

    init(config: AuthConfigProtocol) {
        self.config = config
    }

    // MARK: RealmAuthInteractorProtocol methods
    func login(withEmail email: String, withEncryptedPassword password: String, loginOption option: LoginSyncOption) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password)
        SyncUser.logIn(with: credentials, server: config.serverURL, timeout: config.timeout) { (user, error) in
            if let user = user {
                self.setDefaultRealm(ofUser: user)
                RealmHolder.sharedInstance.shouldSync = (option == .append)
                RealmHolder.sharedInstance.setupNotificationToken()
                self.output?.didLogin(user: user)
            } else {
                self.output?.didFailLogin(withError: error)
            }
        }
    }

    func register(withEmail email: String, withEncryptedPassword password: String, withName name: String) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: true)
        SyncUser.logIn(with: credentials, server: config.serverURL, timeout: config.timeout) { (user, error) in
            if let user = user {
                self.setDefaultRealm(ofUser: user)
                RealmHolder.sharedInstance.shouldSync = true
                RealmHolder.sharedInstance.setupNotificationToken()
                self.saveUserDetails(ofUser: user, withEmail: email, withName: name)
                self.output?.didRegister(user: user)
            } else {
                self.output?.didFailRegistration(withError: error)
            }
        }
    }

    func logout() {
        if SyncUser.current != nil {
            print("logging out user \(String(describing: SyncUser.current?.identity))")
            SyncUser.current?.logOut()
            
            guard let realm = RealmHolder.sharedInstance.userRealm else {
                self.output?.didLogout()
                return
            }
            
            try? realm.write {
                realm.deleteAll()
            }
            
            self.output?.didLogout()
        }
    }

    // MARK: - Realm setup methods
    func setDefaultRealm(ofUser user: RLMSyncUser) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            syncConfiguration: SyncConfiguration(user: user, realmURL: config.userRealmPath)
        )
    }
    
    // MARK: - Registration setup methods
    func saveUserDetails(ofUser user: RLMSyncUser, withEmail email: String, withName name: String) {
        DispatchQueue.main.async {
            guard let userRealm = RealmHolder.sharedInstance.userRealm
            else { return }
            
            let newUser = User(id: user.identity!, name: name, email: email, image: "",
                               currency: Currency.with(isoCode: "PHP", inRealm: userRealm)!)

            newUser.save(toRealm: userRealm)
            let userDetails = RealmHolder.sharedInstance.userRealm!.objects(User.self)
            print(userDetails)
        }
    }
}
