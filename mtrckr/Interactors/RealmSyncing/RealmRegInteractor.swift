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

protocol RealmRegInteractorOutput {
    func didFailRegistration(withError error: Error?)
    func didRegister(user: RLMSyncUser)
}

protocol RealmRegInteractorProtocol {
    func register(withEmail email: String, withEncryptedPassword password: String, withName name: String)
    var output: RealmRegInteractorOutput? { get set }
}
class RealmRegInteractor: RealmRegInteractorProtocol {
    var output: RealmRegInteractorOutput?
    var config: AuthConfigProtocol

    init(config: AuthConfigProtocol) {
        self.config = config
    }

    // MARK: RealmRegInteractorProtocol methods

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
    
    // MARK: - Realm setup methods
    func setDefaultRealm(ofUser user: RLMSyncUser) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            syncConfiguration: SyncConfiguration(user: user, realmURL: config.userRealmPath)
        )
    }
}
