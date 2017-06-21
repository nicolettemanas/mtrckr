//
//  MockRealmHolder.swift
//  mtrckr
//
//  Created by User on 6/20/17.
//
//

import UIKit
import Realm
import RealmSwift
@testable import mtrckr

class MockRealmHolder: RealmHolder {
    init() {
        super.init(withConfig: RealmAuthConfig(), syncUser: MTSyncUser())
    }
    
    override func readOfflineRealm() -> Realm {
        do {
            var offlineConfig = Realm.Configuration()
            offlineConfig.inMemoryIdentifier = "MockRealmContainer"
            
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
        syncConfig.inMemoryIdentifier = "MockRealmContainer-sync"
        
        var userRealm: Realm!
        userRealm = try? Realm(configuration: syncConfig)
        
        return userRealm
    }
}
