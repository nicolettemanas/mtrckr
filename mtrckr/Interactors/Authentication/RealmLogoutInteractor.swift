//
//  RealmLogoutInteractor.swift
//  mtrckr
//
//  Created by User on 6/5/17.
//
//

import UIKit
import Realm
import RealmSwift

/// :nodoc:
protocol RealmLogoutInteractorProtocol {
    func logout()
}

/// :nodoc:
protocol RealmLogoutInteractorOutput {
    func didLogout()
}

/// Class responsible for logging out
class RealmLogoutInteractor: RealmHolder, RealmLogoutInteractorProtocol {
    /// The output delegate of the interactor
    var output: RealmLogoutInteractorOutput?
    
    /// Logs out the current user from the system and deletes
    /// all values in the offline realm
    func logout() {
        if SyncUser.current != nil {
            print("logging out user \(String(describing: SyncUser.current?.identity))")
            SyncUser.current?.logOut()
            guard var realm = self.realmContainer?.userRealm else {
                self.output?.didLogout()
                return
            }
            
            self.realmContainer?.setDefaultRealm(to: .offline)
            realm = self.realmContainer!.userRealm!
            try? realm.write {
                realm.deleteAll()
            }
            self.output?.didLogout()
        }
    }
    
}
