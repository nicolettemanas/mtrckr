//
//  RealmLoginInteractor.swift
//  mtrckr
//
//  Created by User on 6/5/17.
//
//

import UIKit
import Realm
import RealmSwift

protocol RealmLoginInteractorOutput {
    func didFailLogin(withError error: Error?)
    func didLogin(user: MTSyncUser)
}

protocol RealmLoginInteractorProtocol {
    func login(withEmail email: String, withEncryptedPassword password: String, loginOption option: LoginSyncOption)
    var output: RealmLoginInteractorOutput? { get set }
}

class RealmLoginInteractor: RealmHolder, RealmLoginInteractorProtocol {
    
    var output: RealmLoginInteractorOutput?
    
    // MARK: RealmAuthInteractorProtocol methods
    func login(withEmail email: String, withEncryptedPassword password: String, loginOption option: LoginSyncOption) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password)
        SyncUser.logIn(with: credentials, server: config.serverURL, timeout: config.timeout) { (user, error) in
            if let user = user {
                let mt = MTSyncUser(syncUser: user)
                self.setDefaultRealm(ofUser: mt)
                if option == .append {
                    self.syncRealm()
                }
                self.output?.didLogin(user: mt)
            } else {
                self.output?.didFailLogin(withError: error)
            }
        }
    }
    
    // MARK: - Realm setup methods
    func setDefaultRealm(ofUser user: MTSyncUser) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            syncConfiguration: SyncConfiguration(user: user.syncUser!, realmURL: config.userRealmPath)
        )
    }
}
