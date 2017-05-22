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
    func login(withEmail email: String, withPassword password: String)
    func register(withEmail email: String, withPassword password: String, withName name: String)
    func logout()
}
class RealmAuthInteractor: RealmAuthInteractorProtocol {

    var config: AuthConfigProtocol
    var output: RealmAuthInteractorOutput

    init(output: RealmAuthInteractorOutput, config: AuthConfigProtocol) {
        self.output = output
        self.config = config
    }

    // MARK: RealmAuthInteractorProtocol methods
    func login(withEmail email: String, withPassword password: String) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password)

        SyncUser.logIn(with: credentials, server: config.serverURL, timeout: config.timeout) { (user, error) in
            if let user = user {
                self.setDefaultRealm(ofUser: user)
                RealmHolder.sharedInstance.setupNotificationToken()
                self.output.didLogin(user: user)
            } else {
                self.output.didFailLogin(withError: error)
            }
        }
    }

    func register(withEmail email: String, withPassword password: String, withName name: String) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: true)

        SyncUser.logIn(with: credentials, server: config.serverURL, timeout: config.timeout) { (user, error) in
            if let user = user {
                self.setDefaultRealm(ofUser: user)
                RealmHolder.sharedInstance.setupNotificationToken()
                self.saveUserDetails(ofUser: user, withEmail: email, withName: name)
                self.output.didRegister(user: user)
            } else {
                self.output.didFailRegistration(withError: error)
            }
        }
    }

    func logout() {
        if SyncUser.current != nil {
            print("logging out user \(String(describing: SyncUser.current?.identity))")
            SyncUser.current?.logOut()
            self.output.didLogout()
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
            
            let newUser = User(id: user.identity!, name: name, email: email, image: "", currency: self.getOrSaveDefaultCurrency())
            newUser.save(toRealm: userRealm)
            
            let userDetails = RealmHolder.sharedInstance.userRealm!.objects(User.self)
            print(userDetails)
        }
    }

    func getOrSaveDefaultCurrency() -> Currency {
        
        guard let userRealm = RealmHolder.sharedInstance.userRealm
        else {
            fatalError("Cannot setup user realm")
        }
        
        var defaultCurrency: Currency? = nil
        let currency = userRealm.objects(Currency.self)
        print(currency)
        
        defaultCurrency = Currency.with(key: "PHP", inRealm: userRealm)
        if defaultCurrency == nil {
            defaultCurrency = Currency(isoCode: "PHP", symbol: "P", state: "Philippines")
            defaultCurrency?.save(toRealm: userRealm)
        }
        
        return defaultCurrency!
    }
}
