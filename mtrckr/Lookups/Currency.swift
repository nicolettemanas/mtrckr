//
//  Currency.swift
//  MoneyTracker
//
//  Created by User on 2/25/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Currency: Object/*, Mappable, Equatable*/ {
    
    dynamic var isoCode:    String! = ""
    dynamic var symbol:     String! = ""
    dynamic var state:      String! = ""
    
//    let users = LinkingObjects(fromType: User.self, property: "currency")
    
    override static func primaryKey() -> String? {
        return "isoCode"
    }
    
    convenience init(isoCode: String, symbol: String, state: String) {
        self.init()
        self.isoCode = isoCode
        self.symbol = symbol
        self.state = state
    }
    
    // MARK: Required methods
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    // MARK: CRUD operations
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func update(to updatedCurrency: Currency, in realm: Realm) {
        guard self.isoCode == updatedCurrency.isoCode else { return }
        
        do {
            try realm.write {
                realm.add(updatedCurrency, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func delete(in realm: Realm) {
        do {
            try realm.write {
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    static func with(key: String, inRealm realm: Realm) -> Currency? {
        return realm.object(ofType: Currency.self, forPrimaryKey: key) as Currency?
    }
    
    static func all(in realm: Realm) -> Results<Currency> {
        return realm.objects(Currency.self).sorted(byKeyPath: "isoCode", ascending: true)
    }
}
