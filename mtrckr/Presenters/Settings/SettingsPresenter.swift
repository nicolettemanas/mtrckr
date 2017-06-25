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
    func fetchSettingsData() -> [[String]]
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
    func fetchSettingsData() -> [[String]] {
        realm = userRealm
        guard realm != nil else {
            fatalError("No realm provided")
        }
        
        let user = realm?.objects(User.self).first
        if SyncUser.current == nil {
            settingsDetails[0][0] = "None"
        } else {
            settingsDetails[0][0] = realm?.objects(User.self).first?.name ?? ""
        }
        
        settingsDetails[0][1] = user?.currency?.isoCode ?? "Not set"
        settingsDetails[0][2] = "\(Category.all(in: realm!, customized: true).count)"
        
        return settingsDetails
    }
}
