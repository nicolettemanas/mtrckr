//
//  MockRealmContainer.swift
//  mtrckrTests
//
//  Created by User on 6/25/17.
//

import UIKit
import Realm
import RealmSwift
@testable import mtrckr

class MockRealmContainer: RealmContainer {
    var isOffline: Bool = true
    var inMemoryIdentifier: String = ""
    var didCallCurrency = false
    
    init(memoryIdentifier: String) {
        inMemoryIdentifier = memoryIdentifier
        super.init(withConfig: RealmAuthConfig())
    }
    
    required init(withConfig configuration: AuthConfig) {
        super.init(withConfig: configuration)
    }
    
    override var userRealm: Realm? {
        if let realm = try? Realm() {
            if !realm.configuration.inMemoryIdentifier!.contains("sync") &&
                realm.objects(Currency.self).count < 1 {
                populateInitialValues(ofRealm: realm)
            }
            return realm
        }
        
        fatalError("Cannot initialize Realm with given configuration")
    }
    
    override func setDefaultRealm(to option: RealmOption) {
        var configuration = Realm.Configuration()
        switch option {
        case .offline:
            configuration = offlineRealmConfig()
            break
        case .sync:
            configuration.inMemoryIdentifier = "\(inMemoryIdentifier)-sync"
            break
        }
        Realm.Configuration.defaultConfiguration = configuration
    }
    
    override func offlineRealmConfig() -> Realm.Configuration {
        var offlineConfig = Realm.Configuration()
        offlineConfig.inMemoryIdentifier = self.inMemoryIdentifier
        return offlineConfig
    }
    
    override func currency() -> String {
        didCallCurrency = true
        return super.currency()
    }
}
