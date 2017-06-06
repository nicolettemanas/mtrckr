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

protocol RealmLogoutInteractorProtocol {
    func logout()
}

protocol RealmLogoutInteractorOutput {
    func didLogout()
}

class RealmLogoutInteractor: RealmLogoutInteractorProtocol {
    
    var output: RealmLogoutInteractorOutput?
    
    func logout() {
        if SyncUser.current != nil {
            print("logging out user \(String(describing: SyncUser.current?.identity))")
            SyncUser.current?.logOut()
            
            guard let realm = RealmHolder.sharedInstance.userRealm else {
                self.output?.didLogout()
                return
            }
            
            try? realm.write {
                realm.deleteAll()
            }
            
            self.output?.didLogout()
        }
    }
    
}
