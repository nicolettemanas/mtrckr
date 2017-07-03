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

/// A superclass that holds an instance of a class conforming to protocol `RealmContainerProtocol`
class RealmHolder: NSObject {
    /// The container of the Realm methods
    var realmContainer: RealmContainerProtocol?
    
    /// The getter of the configuration used by the realm container
    var config: AuthConfig? {
        return self.realmContainer?.config
    }
    
    /// Initializes the with the given `AuthConfig` to be used when
    /// initializing the `realmContainer`
    ///
    /// - Parameter config: The configuration to be used
    init(with config: AuthConfig) {
        self.realmContainer = RealmContainer(withConfig: config)
    }
}

/// :nodoc:
protocol RealmContainerProtocol {
    var config: AuthConfig { get }
    var userRealm: Realm? { get }
    
    init(withConfig configuration: AuthConfig)
    
    func setDefaultRealm(to option: RealmOption)
    func syncRealm()
    func offlineRealmConfig() -> Realm.Configuration
    func currency() -> String
}

/// Collection of Realm options to be used
///
/// - offline: Uses the offline URL provided in the configuration given
/// - sync: Uses the sync URL provided in the configuration given
enum RealmOption {
    case offline
    case sync
}

/// `RealmContainer` is a class containing all methods necessary to interact with offline and online Realms
class RealmContainer: RealmContainerProtocol {
    
    // MARK: - Properties
    
    /// The configuration of the realm to be used
    private(set) var config: AuthConfig
    
    /// Returns the realm to be used.
    /// Returns a sync realm if a user is logged in the system, otherwise returns an offline realm
    var userRealm: Realm? {
        var config = getConfig(of: .offline)
        if SyncUser.current != nil {
            config = getConfig(of: .sync)
        }
        
        if let realm = try? Realm(configuration: config) {
            if realm.configuration.syncConfiguration == nil &&
                realm.objects(Currency.self).count < 1 {
                populateInitialValues(ofRealm: realm)
            }
            return realm
        }
        
        fatalError("Cannot initialize Realm with given configuration")
    }
    
    // MARK: - Initializers
    /// Creates a RealmHolder that has the given configuration
    ///
    /// - Parameter configuration: The configuration of the realm to be used
    required init(withConfig configuration: AuthConfig) {
        self.config = configuration
    }
    
    func getConfig(of option: RealmOption) -> Realm.Configuration {
        var configuration = Realm.Configuration()
            switch option {
            case .offline:
                configuration = offlineRealmConfig()
                break
            case .sync:
                assert(RLMSyncUser.current != nil)
                configuration.syncConfiguration = SyncConfiguration(user: RLMSyncUser.current!,
                                                                    realmURL: config.userRealmPath)
                break
            }
        return configuration
    }
    
    // MARK: - Realm methods
    
    /// Sets the default configuration of the Realm to be fetched.
    /// Realm URLs will be from the configuration provided
    /// upon initilization.
    ///
    /// - Parameter option: The preferred Realm option. See `RealmOption`
    func setDefaultRealm(to option: RealmOption) {
        var configuration = Realm.Configuration()
        switch option {
            case .offline:
                configuration = offlineRealmConfig()
                break
            case .sync:
                assert(RLMSyncUser.current != nil)
                configuration.syncConfiguration = SyncConfiguration(user: RLMSyncUser.current!,
                                                                    realmURL: config.userRealmPath)
                break
        }
        
        // TODO: Encrypt Realm in prod config
//        guard let key = Bundle.main.object(forInfoDictionaryKey: "ENCRYPTION_KEY") as? String else {
//            fatalError("Cannot read key")
//        }
//        configuration.encryptionKey = Data(base64Encoded: key)
        Realm.Configuration.defaultConfiguration = configuration
    }
    
    /// Migrates the offline realm values to the sync realm to be used.
    /// 
    /// Locations of these realms are all defined in the configuration used.
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
    private func readOfflineRealm() -> Realm {
        do {
            let offlineConfig = offlineRealmConfig()
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
    
    /// Returns the offline realm configuration built from the provided `AuthConfig`
    ///
    /// - Returns: The realm configuration
    func offlineRealmConfig() -> Realm.Configuration {
        var offlineConfig = Realm.Configuration()
        offlineConfig.fileURL = offlineConfig.fileURL!
            .deletingLastPathComponent()
            .appendingPathComponent("initRealm/\(config.offlineRealmFileName).realm")
        return offlineConfig
    }
    
    /// Returns the currency symbol used by the logged in user.
    /// Default value is ₱
    ///
    /// - Returns: The currency symbol
    func currency() -> String {
        if let realm = userRealm {
            return User.all(in: realm).first?.currency?.symbol ?? "₱"
        }
        
        return "₱"
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
