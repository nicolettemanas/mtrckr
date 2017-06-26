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

/// Wrapper class for `RLMSyncUser` that holds the RLMSyncUser
/// as nullable for testing purposes
@objc class MTSyncUser: NSObject {
    
    /// The `RLMSyncUser` assigned to the wrapper
    var syncUser: RLMSyncUser?
    
    /// A unique string identifier for the instance
    /// Returns the original identity of `RLMSyncUser`, creates a new UUIDstring
    /// if `RLMSyncUser` is nil
    var identity: String {
        if let sUser = syncUser {
            return sUser.identity!
        } else {
            return UUID().uuidString
        }
    }
    
    /// Returns the current `RLMSyncUser` wrapped in `MTSyncUser`
    /// Value may be nil when there is no logged in user
    static var current: MTSyncUser? {
        if let realmCurrent = SyncUser.current {
            return MTSyncUser(syncUser: realmCurrent)
        } else {
            return nil
        }
    }
    
    // MARK: - Initializers
    
    /// Creates an `MTSyncUser` with nil values
    override init() {
        super.init()
    }
    
    /// Creates an `MTSyncUser` with the given `RLMSyncUser`
    ///
    /// - Parameter syncUser: The SyncUser to be stored
    init(syncUser: RLMSyncUser) {
        self.syncUser = syncUser
    }
}

/// :nodoc:
protocol RealmRegInteractorOutput {
    func didFailRegistration(withError error: Error?)
    func didRegister(user: MTSyncUser)
}

/// :nodoc:
protocol RealmRegInteractorProtocol {
    func register(withEmail email: String, withEncryptedPassword password: String, withName name: String)
    var output: RealmRegInteractorOutput? { get set }
}

/// Class responsible for registration
class RealmRegInteractor: RealmHolder, RealmRegInteractorProtocol {
    
    /// The output delegate of the interactor
    var output: RealmRegInteractorOutput?

    // MARK: RealmRegInteractorProtocol methods
    /// Receives encrypted credentials and informs output of the results
    ///
    /// - Parameters:
    ///   - email: The email of the user to be registered
    ///   - password: The encrypted password of the user to be registered
    ///   - name: The name of the user to be registered
    func register(withEmail email: String, withEncryptedPassword password: String, withName name: String) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: true)
        registerUser(withCredentials: credentials, server: config!.serverURL,
                     timeout: config!.timeout) { (user, error) in
            if error == nil {
                self.realmContainer?.setDefaultRealm(to: .sync)
                self.realmContainer?.syncRealm()
                self.saveUserDetails(ofUser: user!, withEmail: email, withName: name)
                self.output?.didRegister(user: user!)
            } else {
                self.realmContainer?.setDefaultRealm(to: .offline)
                self.output?.didFailRegistration(withError: error)
            }
        }
    }
    
    // MARK: - Registration
    
    /// Saves user details to the syncRealm
    ///
    /// - Parameters:
    ///   - user: The MTSyncUser containing the details to be saved
    ///   - email: The email registered
    ///   - name: The name registered
    func saveUserDetails(ofUser user: MTSyncUser, withEmail email: String, withName name: String) {
        DispatchQueue.main.async {
            guard let userRealm = self.realmContainer?.userRealm
            else { return }
            
            let newUser = User(id: user.identity, name: name, email: email, image: "",
                               currency: Currency.with(isoCode: "PHP", inRealm: userRealm)!)

            newUser.save(toRealm: userRealm)
        }
    }
    
    /// The implementation of the registration process
    ///
    /// - Parameters:
    ///   - credentials: The collection of data to be registered
    ///   - server: The server URL of the Realm Object Server
    ///   - timeout: Timeout in seconds
    ///   - completion: Block to execute upon finishing registration given the `MTSyncUser` registered
    ///     and the error encountered if available
    func registerUser(withCredentials credentials: SyncCredentials, server: URL,
                      timeout: TimeInterval, completion:@escaping (_ user: MTSyncUser?, _ error: Error?) -> Void) {
        
        SyncUser.logIn(with: credentials, server: server, timeout: config!.timeout) { (user, error) in
            
            if let syncUser = user {
                let mt = MTSyncUser(syncUser: syncUser)
                completion(mt, error)
            } else {
                completion(nil, error)
            }
        }
    }
}
