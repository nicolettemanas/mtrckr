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

@objc class MTSyncUser: NSObject {
    var syncUser: RLMSyncUser?
    var identity: String {
        if let sUser = syncUser {
            return sUser.identity!
        } else {
            return UUID().uuidString
        }
    }
    
    static var current: MTSyncUser? {
        if let realmCurrent = SyncUser.current {
            return MTSyncUser(syncUser: realmCurrent)
        } else {
            return nil
        }
    }
    
    override init() {
        super.init()
    }
    
    init(syncUser: RLMSyncUser) {
        self.syncUser = syncUser
    }
    
}

protocol RealmRegInteractorOutput {
    func didFailRegistration(withError error: Error?)
    func didRegister(user: MTSyncUser)
}

protocol RealmRegInteractorProtocol {
    func register(withEmail email: String, withEncryptedPassword password: String, withName name: String)
    var output: RealmRegInteractorOutput? { get set }
}

class RealmRegInteractor: RealmHolder, RealmRegInteractorProtocol {
    var output: RealmRegInteractorOutput?

    // MARK: RealmRegInteractorProtocol methods
    func register(withEmail email: String, withEncryptedPassword password: String, withName name: String) {
        let credentials = SyncCredentials.usernamePassword(username: email, password: password, register: true)
        registerUser(withCredentials: credentials, server: config.serverURL,
                     timeout: config.timeout) { (user, error) in
            if error == nil {
                self.syncRealm()
                self.saveUserDetails(ofUser: user!, withEmail: email, withName: name)
                self.output?.didRegister(user: user!)
            } else {
                self.output?.didFailRegistration(withError: error)
            }
        }
    }
    
    // MARK: - Registration setup methods
    func saveUserDetails(ofUser user: MTSyncUser, withEmail email: String, withName name: String) {
        DispatchQueue.main.async {
            guard let userRealm = self.userRealm
            else { return }
            
            let newUser = User(id: user.identity, name: name, email: email, image: "",
                               currency: Currency.with(isoCode: "PHP", inRealm: userRealm)!)

            newUser.save(toRealm: userRealm)
        }
    }
    
    // MARK: - Registration methods
    func registerUser(withCredentials credentials: SyncCredentials, server: URL,
                      timeout: TimeInterval, completion:@escaping (_ user: MTSyncUser?, _ error: Error?) -> Void) {
        
        SyncUser.logIn(with: credentials, server: config.serverURL, timeout: config.timeout) { (user, error) in
            
            if let syncUser = user {
                let mt = MTSyncUser(syncUser: syncUser)
                completion(mt, error)
            } else {
                completion(nil, error)
            }
        }
    }
}
