//
//  GlobalRealm.swift
//  mtrckr
//
//  Created by User on 5/19/17.
//
//

import UIKit
import Realm
import RealmSwift

protocol RealmHolderProtocol {
    var realmHolder: RealmHolder? { get set }
    var config: AuthConfigProtocol { get set }
}

class RealmHolder {
    var config: AuthConfigProtocol
    var syncUser: MTSyncUser?

    init(withConfig configuration: AuthConfigProtocol) {
        self.config = configuration
    }
    
    init(withConfig configuration: AuthConfigProtocol, syncUser: MTSyncUser?) {
        self.config = configuration
        self.syncUser = syncUser
    }
    
    var userRealm: Realm? {
        if self.syncUser == nil {
            return readOfflineRealm()
        } else {
           return getSyncedRealm()
        }
    }

    // MARK: - Realm methods
    func syncRealm() {
        guard let uRealm = self.userRealm else {
            fatalError("Sync realm is nil")
        }
        
        let offlineRealm = readOfflineRealm()
        migrate(objects: config.objects, fromRealm: offlineRealm, toRealm: uRealm)
    }
    
    func populateInitialValues(ofRealm realm: Realm) {
        do {
            print("Populating initial values...")
            let initConfig = Realm.Configuration(fileURL: config.initialRealm)
            let initDbRealm = try Realm(configuration: initConfig)
            migrate(objects: config.objects, fromRealm: initDbRealm, toRealm: realm)
        } catch let error as NSError {
            fatalError("Cannot initialize offline user realm with error: \(error)")
        }
    }
    
    func readOfflineRealm() -> Realm {
        do {
            var offlineConfig = Realm.Configuration()
            offlineConfig.fileURL = offlineConfig.fileURL!
                .deletingLastPathComponent()
                .appendingPathComponent("initRealm/\(config.offlineRealmFileName).realm")
            
            let offlineRealm = try Realm(configuration: offlineConfig)
            if offlineRealm.objects(Currency.self).count < 1 {
                populateInitialValues(ofRealm: offlineRealm)
            }
            print("[REALM] offline realm: \(String(describing: offlineRealm.configuration.fileURL))")
            return offlineRealm
        } catch let error as NSError {
            fatalError("Cannot initialize offline user realm with error: \(error)")
        }
    }
    
    func getSyncedRealm() -> Realm {
        guard let sUser = syncUser?.syncUser else {
            fatalError("SyncUser is nil; no logged in user")
        }
        
        setDefaultConfiguration(user: sUser, url: config.userRealmPath)
        var userRealm: Realm!
        userRealm = try? Realm()
        
        print("[REALM]sync realm: \(String(describing: userRealm.configuration.syncConfiguration?.realmURL))")
        return userRealm
    }
    
    func setDefaultConfiguration(user: SyncUser, url: URL) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            syncConfiguration: SyncConfiguration(user: user,
                                                 realmURL: url)
        )
    }
    
    // MARK: - Migrating between realms
    private func migrate(objects: [String], fromRealm source: Realm, toRealm destination: Realm) {
        do {
            try destination.write({
                for object in objects {
                    let localObjects = source.dynamicObjects(object)
                    _ = localObjects.reduce(List<DynamicObject>()) { (list, element) -> List<DynamicObject> in
                        destination.dynamicCreate(object, value: element, update: true)
                        return list
                    }
                }
            })
        } catch let error as NSError {
            fatalError("Unable to perform migration syncing offline data \(error)")
        }
    }
}
