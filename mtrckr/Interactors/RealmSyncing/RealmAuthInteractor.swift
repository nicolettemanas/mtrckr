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
    func didLogout(user: User)
}

protocol RealmAuthInteractorProtocol {
    func login(withEmail email: String, withPassword password: String, toServer server: URL)
    func register(withEmail email: String, withPassword password: String, toServer server: URL)
    func logout(user: User)
}
class RealmAuthInteractor: RealmAuthInteractorProtocol {
    var output: RealmAuthInteractorOutput?
    let timeout = TimeInterval(30)
    init(output: RealmAuthInteractorOutput?) {
        self.output = output
    }

    // MARK: RealmAuthInteractorProtocol methods
    func login(withEmail email: String, withPassword password: String, toServer server: URL) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password)
        SyncUser.logIn(with: credentials, server: server, timeout: timeout) { (user, error) in
            if let user = user {
                self.output?.didLogin(user: user)
            } else {
                self.output?.didFailLogin(withError: error)
            }
        }
    }

    func register(withEmail email: String, withPassword password: String, toServer server: URL) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: true)
        SyncUser.logIn(with: credentials, server: server, timeout: timeout) { (user, error) in
            if let user = user {
                DispatchQueue.main.async {
                    let configuration = Realm.Configuration(
                        syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://localhost:9080/shared-dev")!),
                        objectTypes: [Currency.self, AccountType.self, Category.self]
                    )

                    guard let realm = try? Realm(configuration: configuration) else {
                        self.output?.didFailLogin(withError: nil)
                        return
                    }

                    var defaultCurrency = Currency.with(key: "PHP", inRealm: realm)
                    if defaultCurrency == nil {
                        defaultCurrency = Currency(isoCode: "PHP", symbol: "P", state: "Philippines")
                        defaultCurrency?.save(toRealm: realm)
                    }

//                    let newUser = User(id: user.identity!, name: "", email: email, image: "", currency: defaultCurrency!)
//                    newUser.save(toRealm: realm)

                    self.output?.didLogin(user: user)
                }
            } else {
                self.output?.didFailLogin(withError: error)
            }
        }
    }
    
    func logout(user: User) {
        if SyncUser.current?.identity == user.id {
            SyncUser.current?.logOut()
            self.output?.didLogout(user: user)
        }
    }
    
    // MARK: - Registration setup methods
    
}
