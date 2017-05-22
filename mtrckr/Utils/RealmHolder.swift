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

    var userRealm: Realm? {
        guard SyncUser.current != nil else {
            return nil
        }
        
        do {
            let userRealm = try Realm()
            return userRealm
        } catch let error as NSError {
            fatalError("Cannot initialize user realm with error: \(error)")
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
}
