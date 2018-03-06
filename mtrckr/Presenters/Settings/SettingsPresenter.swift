//
//  SettingsPresenter.swift
//  mtrckr
//
//  Created by User on 6/16/17.
//
//

import UIKit
import Realm
import RealmSwift

/// :nodoc:
protocol SettingsPresenterProtocol {
    func fetchSettingsData(_ fetched:@escaping ([[String]]) -> Void)
}

/// The event handler for `SettingsTableViewController`
class SettingsPresenter: RealmHolder, SettingsPresenterProtocol {

    /// Extracts data from the realm used and returns values to be displayed in the settings table
    ///
    /// - Returns: An collection of array of Strings to be displayed in the settings table
    func fetchSettingsData(_ fetched:@escaping ([[String]]) -> Void) {
        if SyncUser.current == nil {
            let realm = self.realmContainer?.userRealm

            var details: [[String]] = [["None", "Not set", "0"], [""]]
            details[0][0] = "None"
            details[0][1] = "Not set"
            details[0][2] = "\(Category.all(in: realm!, customized: true).count)"
            fetched(details)
        } else {
            let realm = self.realmContainer?.userRealm
            guard realm != nil else {
                fatalError("No realm provided")
            }

            let user = User.all(in: realm!).first
            if user == nil {
                fatalError("No User found in realm")
            }

            var details: [[String]] = [["None", "Not set", "0"], [""]]
            details[0][0] = user?.name ?? ""
            details[0][1] = user?.currency?.isoCode ?? "Not set"
            details[0][2] = "\(Category.all(in: realm!, customized: true).count)"
            fetched(details)
        }
    }
}
