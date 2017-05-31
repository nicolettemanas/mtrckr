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

class RealmHolder {
    static let sharedInstance = RealmHolder(config: RealmAuthConfig())

    private var config: AuthConfigProtocol
    private var userNotificationToken: NotificationToken!
    private var didSync: Bool = false
    
    var shouldSync: Bool = false

    var userRealm: Realm? {
        if SyncUser.current == nil {
            do {
                let offlineRealm = getOfflineRealm()
                if offlineRealm.objects(Currency.self).count < 1 {
                    let initConfig = Realm.Configuration(fileURL: config.initialRealm)
                    let initDbRealm = try Realm(configuration: initConfig)
                    migrate(objects: config.objects, fromRealm: initDbRealm, toRealm: offlineRealm)
                }
                
                print("offline realm: \(String(describing: offlineRealm.configuration.fileURL))")
                return offlineRealm
            } catch let error as NSError {
                fatalError("Cannot initialize offline user realm with error: \(error)")
            }
        } else {
            do {
                let userRealm = try Realm()
                if didSync == false && shouldSync == true {
                    let offlineRealm = getOfflineRealm()
                    migrate(objects: config.objects, fromRealm: offlineRealm, toRealm: userRealm)
                    didSync = true
                }
                
                print("sync realm: \(String(describing: userRealm.configuration.syncConfiguration?.realmURL))")
                return userRealm
            } catch let error as NSError {
                fatalError("Cannot initialize user realm with error: \(error)")
            }
        }
    }
    
    init(config: AuthConfigProtocol) {
        self.config = config
    }

    // MARK: - Realm methods
    func setupNotificationToken() {
        DispatchQueue.main.async {
            self.userNotificationToken = self.userRealm?.addNotificationBlock { _ in
                print("User realm updated")
            }
        }
    }
    
    func getOfflineRealm() -> Realm {
        do {
            var offlineConfig = Realm.Configuration()
            offlineConfig.fileURL = offlineConfig.fileURL!.deletingLastPathComponent()
                                    .appendingPathComponent("/initRealm/\(config.offlineRealmFileName).realm")
            let offlineRealm = try Realm(configuration: offlineConfig)
            return offlineRealm
        } catch let error as NSError {
            fatalError("Cannot initialize offline user realm with error: \(error)")
        }
    }
    
    // MARK: - Migrating between realms
    private func migrate(objects: [String], fromRealm source: Realm, toRealm destination: Realm) {
        do {
            print("Migrating contents of \(String(describing: source.configuration.fileURL?.lastPathComponent)) to \(String(describing: destination.configuration.fileURL?.lastPathComponent))")
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
