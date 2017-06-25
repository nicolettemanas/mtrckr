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

//protocol RealmHolderProtocol {
//    var realmHolder: RealmHolder? { get set }
//    var config: AuthConfig { get set }
//}

/// `RealmHolder` is a superclass containing all necessary methods to interact with offline and online Realms
class RealmHolder {
    
    // MARK: - Properties
    
    /// The configuration of the realm to be used
    var config: AuthConfig
    
    /// The current syncd user
    /// Must be nil if there is no user logged in
    var syncUser: MTSyncUser?

    /// Returns the realm to be used
    /// Returns a sync realm if a user is logged in the system, otherwise returns an offline realm
    var userRealm: Realm? {
        if self.syncUser == nil {
            return readOfflineRealm()
        } else {
            return getSyncedRealm()
        }
    }
    
    // MARK: - Initializers
    /// Creates a RealmHolder that has the given configuration
    ///
    /// - Parameter configuration: The configuration of the realm to be used
    init(withConfig configuration: AuthConfig) {
        self.config = configuration
    }
    
    /// Creates a RealmHolder that has the given configuration and syncUser
    ///
    /// - Parameters:
    ///   - configuration: The configuration of the realm to be used
    ///   - syncUser: The current syned user
    init(withConfig configuration: AuthConfig, syncUser: MTSyncUser?) {
        self.config = configuration
        self.syncUser = syncUser
    }

    // MARK: - Realm methods
    
    /// Migrates the offline realm values to the sync realm to be used
    /// 
    /// Locations of these realms are all defined in the configuration used
    func syncRealm() {
        guard let uRealm = self.userRealm else {
            fatalError("Sync realm is nil")
        }
        
        let offlineRealm = readOfflineRealm()
        migrate(objects: config.objects, fromRealm: offlineRealm, toRealm: uRealm)
        print("[REALM] Synced offline realm to syncRealm...")
    }

    /// Copies the initial values from the initial Realm specified in the configuration
    /// to the given realm
    ///
    /// - Parameter realm: The realm to be populated
    func populateInitialValues(ofRealm realm: Realm) {
        do {
            let initConfig = Realm.Configuration(fileURL: config.initialRealm)
            let initDbRealm = try Realm(configuration: initConfig)
            migrate(objects: config.objects, fromRealm: initDbRealm, toRealm: realm)
            print("[REALM] Populated offline realm with initial values...")
        } catch let error as NSError {
            fatalError("Cannot initialize offline user realm with error: \(error)")
        }
    }
    
    /// Retrieves the Offline Realm specified in the configuration
    ///
    /// - Returns: The Realm read from the static offline configuration URL
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
            print("[REALM] did read offline realm: \(String(describing: offlineRealm.configuration.fileURL?.lastPathComponent))")
            return offlineRealm
        } catch let error as NSError {
            fatalError("Cannot initialize offline user realm with error: \(error)")
        }
    }
    
    /// Retrieves the Synced Realm specified in the configuration
    ///
    /// - Returns: The Realm read from the static sync configuration URL
    func getSyncedRealm() -> Realm {
        guard let sUser = syncUser?.syncUser else {
            fatalError("SyncUser is nil; no logged in user")
        }
        
        setDefaultConfiguration(user: sUser, url: config.userRealmPath)
        var userRealm: Realm!
        userRealm = try? Realm()
        
        print("[REALM] did get sync realm: \(String(describing: userRealm.configuration.syncConfiguration?.realmURL.lastPathComponent))")
        return userRealm
    }
    
    /// :nodoc:
    private func setDefaultConfiguration(user: SyncUser, url: URL) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            syncConfiguration: SyncConfiguration(user: user,
                                                 realmURL: url)
        )
    }
    
    // MARK: - Migrating between realms
    /// :nodoc:
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
