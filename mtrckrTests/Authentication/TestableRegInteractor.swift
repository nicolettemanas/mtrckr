//
//  MockRegInteractor.swift
//  mtrckr
//
//  Created by User on 6/15/17.
//
//

import UIKit
@testable import mtrckr
import RealmSwift
import Realm

class TestableRegInteractor: RealmRegInteractor {
    var didRegister = false
    var inMemoryIdentifier: String
    
    init(_ inMemoryIdentifier: String) {
        self.inMemoryIdentifier = inMemoryIdentifier
        super.init(withConfig: RealmAuthConfig(), syncUser: MTSyncUser())
    }
    
    override func registerUser(withCredentials credentials: SyncCredentials, server: URL,
                               timeout: TimeInterval, completion:@escaping (_ user: MTSyncUser?, _ error: Error?) -> Void) {
        didRegister = true
        self.syncUser = MTSyncUser()
        completion(self.syncUser, nil)
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
}
