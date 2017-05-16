//
//  RealmAuthPresenter.swift
//  mtrckr
//
//  Created by User on 5/16/17.
//
//

import UIKit
import Realm
import RealmSwift

class RealmAuthPresenter: RealmAuthInteractorOutput {

    // MARK: RealmAuthInteractorOutput
    func didLogin(user: RLMSyncUser) {
        DispatchQueue.main.async {
            print("did login \(user)")

            let transactions = try! Realm().objects(Currency.self)
            print(transactions)
        }
        
    }

    func didFailLogin(withError error: Error?) {
        print("did fail login \(String(describing: error))")
    }

    func didFailRegistration(withError error: Error?) {

    }
    
    func didRegister(user: RLMSyncUser) {

    }
    
    func didLogout(user: User) {

    }

}
