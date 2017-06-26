//
//  MockRealmHolder.swift
//  mtrckrTests
//
//  Created by User on 6/25/17.
//

import UIKit
import Realm
import RealmSwift
@testable import mtrckr

//class MockRealmHolder: RealmHolder {
//    override func offlineRealmConfig() -> Realm.Configuration {
//        var offlineConfig = Realm.Configuration()
//        offlineConfig.inMemoryIdentifier = self.inMemoryIdentifier
//        return offlineConfig
//    }
//
//    override func setDefaultRealm(to option: RealmOption) {
//        var configuration = Realm.Configuration()
//        realmOption = option
//
//        switch option {
//        case .offline:
//            configuration = offlineRealmConfig()
//        case .sync:
//            configuration.inMemoryIdentifier = "\(self.inMemoryIdentifier)-sync"
//        }
//
//        Realm.Configuration.defaultConfiguration = configuration
//    }
//}

