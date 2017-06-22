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
        loginUser(withCredentials: credentials, server: config.serverURL, timeout: config.timeout) { (user, error) in
            if error == nil {
                if option == .append {
                    self.syncRealm()
                }
                self.output?.didLogin(user: user!)
            } else {
                self.output?.didFailLogin(withError: error)
            }
        }
    }
    
    // MARK: - Realm Login methods
    func loginUser(withCredentials credentials: SyncCredentials,
                   server: URL,
                   timeout: TimeInterval,
                   completion: @escaping (MTSyncUser?, Error?) -> Void) {
        
        SyncUser.logIn(with: credentials, server: server, timeout: timeout) { (user, error) in
            if let syncUser = user {
                let mt = MTSyncUser(syncUser: syncUser)
                completion(mt, error)
            } else {
                completion(nil, error)
            }
        }
    }
}
