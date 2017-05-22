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
        print(":: did login \(user)")
    }

    func didFailLogin(withError error: Error?) {
        print(":: did fail login \(String(describing: error))")
    }

    func didFailRegistration(withError error: Error?) {
        print(":: did fail registration \(String(describing: error))")
    }

    func didRegister(user: RLMSyncUser) {
        print(":: did register user \(String(describing: user.identity))")
    }

    func didLogout() {
        print(":: did log out")
    }
}
