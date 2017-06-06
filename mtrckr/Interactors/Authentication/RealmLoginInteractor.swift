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
    func didLogin(user: RLMSyncUser)
}

protocol RealmLoginInteractorProtocol {
    func login(withEmail email: String, withEncryptedPassword password: String, loginOption option: LoginSyncOption)
    var output: RealmLoginInteractorOutput? { get set }
}

class RealmLoginInteractor: RealmLoginInteractorProtocol {
    
    var output: RealmLoginInteractorOutput?
    var config: AuthConfigProtocol
    
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
    
    // MARK: - Realm setup methods
    func setDefaultRealm(ofUser user: RLMSyncUser) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            syncConfiguration: SyncConfiguration(user: user, realmURL: config.userRealmPath)
        )
    }
}
