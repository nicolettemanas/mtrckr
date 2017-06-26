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
    
    /// The current realm being used
    var realm: Realm?
    
    /// :nodoc:
    var settingsDetails: [[String]] = [["None", "Not set", "0"], [""]]
    
    /// Extracts data from the realm used and returns values to be displayed in the settings table
    ///
    /// - Returns: An collection of array of Strings to be displayed in the settings table
    func fetchSettingsData(_ fetched:@escaping ([[String]]) -> Void) {
        DispatchQueue.main.async {
            self.realm = self.realmContainer?.userRealm
            guard self.realm != nil else {
                fatalError("No realm provided")
            }
            
            let user = self.realm?.objects(User.self).first
            if SyncUser.current == nil {
                self.settingsDetails[0][0] = "None"
            } else {
                self.settingsDetails[0][0] = self.realm?.objects(User.self).first?.name ?? ""
            }
            
            self.settingsDetails[0][1] = user?.currency?.isoCode ?? "Not set"
            self.settingsDetails[0][2] = "\(Category.all(in: self.realm!, customized: true).count)"
            
            fetched(self.settingsDetails)
        }
    }
}
