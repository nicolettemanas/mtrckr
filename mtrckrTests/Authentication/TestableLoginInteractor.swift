//
//  TestableLoginInteractor.swift
//  mtrckr
//
//  Created by User on 6/21/17.
//
//

import UIKit
import RealmSwift
import Realm

@testable import mtrckr

class TestableLoginInteractor: RealmLoginInteractor {
    
    var didLogin = false
    var inMemoryIdentifier: String
    
    init(_ inMemoryIdentifier: String) {
        self.inMemoryIdentifier = inMemoryIdentifier
        super.init(withConfig: RealmAuthConfig(), syncUser: MTSyncUser())
    }
    
    override func readOfflineRealm() -> Realm {
        do {
            var offlineConfig = Realm.Configuration()
            offlineConfig.inMemoryIdentifier = self.inMemoryIdentifier
            
            let offlineRealm = try Realm(configuration: offlineConfig)
            if offlineRealm.objects(Currency.self).count < 1 {
                populateInitialValues(ofRealm: offlineRealm)
            }
            
            return offlineRealm
        } catch let error as NSError {
            fatalError("Cannot initialize offline user realm with error: \(error)")
        }
    }
    
    override func getSyncedRealm() -> Realm {
        var syncConfig = Realm.Configuration()
        syncConfig.inMemoryIdentifier = "\(self.inMemoryIdentifier)-sync"
        
        var userRealm: Realm!
        userRealm = try? Realm(configuration: syncConfig)
        
        return userRealm
    }
    
    override func loginUser(withCredentials credentials: SyncCredentials,
                            server: URL, timeout: TimeInterval,
                            completion: @escaping (MTSyncUser?, Error?) -> Void) {
        didLogin = true
        self.syncUser = MTSyncUser()
        completion(self.syncUser, nil)
    }
}

class StubFailedLoginInteractor: RealmLoginInteractor {
    
    init() {
        super.init(withConfig: RealmAuthConfig(), syncUser: MTSyncUser())
    }
    
    override func loginUser(withCredentials credentials: SyncCredentials,
                            server: URL, timeout: TimeInterval,
                            completion: @escaping (MTSyncUser?, Error?) -> Void) {
        
        let customError = NSError(domain: "", code: 500, userInfo: nil)
        completion(MTSyncUser(), customError as Error)
    }
}
