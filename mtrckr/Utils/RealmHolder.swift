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
    private var offlineRealm: Realm!

    var userRealm: Realm? {
        if self.offlineRealm != nil && SyncUser.current == nil {
            return self.offlineRealm
        }
        
        if SyncUser.current == nil {
            do {
                let offlineConfig = Realm.Configuration(fileURL: config.offlineRealm)
                self.offlineRealm = try Realm(configuration: offlineConfig)
                return self.offlineRealm
            } catch let error as NSError {
                fatalError("Cannot initialize offline user realm with error: \(error)")
            }
        } else {
            do {
                let userRealm = try Realm()
                migrate(objects: config.objects, toSyncRealm: userRealm)
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
                print("Updated user realm")
                _ = self.userRealm
            }
        }
    }
    
    // MARK: - Migrate from offline to syncRealm
    private func migrate(objects: [String], toSyncRealm realm: Realm) {
        do {
            try realm.write({
                for object in objects {
                    let localObjects = self.offlineRealm.dynamicObjects(object)
                    _ = localObjects.reduce(List<DynamicObject>()) { (list, element) -> List<DynamicObject> in
                        realm.dynamicCreate(object, value: element, update: true)
                        return list
                    }
                }
            })
        } catch let error as NSError {
            fatalError("Unable to perform migration syncing offline data \(error)")
        }
    }
}
