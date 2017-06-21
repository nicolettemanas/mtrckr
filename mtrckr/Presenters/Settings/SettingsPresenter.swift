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

protocol SettingsPresenterProtocol {
    func fetchSettingsData() -> [[String]]
}

class SettingsPresenter: RealmHolder, SettingsPresenterProtocol {
    
    var realm: Realm?
    var settingsDetails: [[String]] = [["None", "Not set", "0"], [""]]
    
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
