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

/// :nodoc:
protocol RealmLoginInteractorOutput {
    func didFailLogin(withError error: Error?)
    func didLogin(user: MTSyncUser)
}

/// :nodoc:
protocol RealmLoginInteractorProtocol {
    func login(withEmail email: String, withEncryptedPassword password: String, loginOption option: LoginSyncOption)
    var output: RealmLoginInteractorOutput? { get set }
}

/// Class responsible for loggin in
class RealmLoginInteractor: RealmHolder, RealmLoginInteractorProtocol {
    
    /// The output delegate of the interactor
    var output: RealmLoginInteractorOutput?
    
    // MARK: RealmAuthInteractorProtocol methods

    /// Receives the encrypted credentials, logs in user and performs
    /// necessary actions to the offline and sync realms
    ///
    /// - Parameters:
    ///   - email: The email of the user to login
    ///   - password: The encrypted password of the user to login
    ///   - option: The `LoginSyncOption` the user selected upon logging in
    func login(withEmail email: String, withEncryptedPassword password: String, loginOption option: LoginSyncOption) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password)
        loginUser(withCredentials: credentials, server: config!.serverURL, timeout: config!.timeout) { (user, error) in
            if error == nil {
                self.realmContainer?.setDefaultRealm(to: .sync)
                if option == .append {
                    self.realmContainer?.syncRealm()
                }
                self.output?.didLogin(user: user!)
            } else {
                self.realmContainer?.setDefaultRealm(to: .offline)
                self.output?.didFailLogin(withError: error)
            }
        }
    }
    
    /// The implementation of the login process
    ///
    /// - Parameters:
    ///   - credentials: The colledtion of data to login
    ///   - server: The server URL of the Realm Object Server
    ///   - timeout: Timeout in seconds
    ///   - completion: Block to execute upon finishing the login process
    ///     given the `MTSyncUser` logged in and the error encountered if available
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
