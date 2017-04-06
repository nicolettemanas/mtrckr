//
//  AccountType.swift
//  MoneyTracker
//
//  Created by User on 2/25/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class AccountType: Object {
    
    dynamic var typeId: Int = 0
    dynamic var name: String = ""
    dynamic var icon: String = ""
    let accounts = LinkingObjects(fromType: Account.self, property: "type")
    
    override static func primaryKey() -> String? {
        return "typeId"
    }
    
    convenience init(typeId: Int, name: String, icon: String) {
        self.init()
        self.typeId = typeId
        self.name = name
        self.icon = icon
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
    
    func update(to updatedAccountType: AccountType, in realm: Realm) {
        guard self.typeId == updatedAccountType.typeId else { return }
        
        do {
            try realm.write {
                realm.add(updatedAccountType, update: true)
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

    static func with(key: Int, inRealm realm: Realm) -> AccountType? {
        return realm.object(ofType: AccountType.self, forPrimaryKey: key) as AccountType?
    }
    
    static func all(in realm: Realm) -> Results<AccountType> {
        return realm.objects(AccountType.self).sorted(byKeyPath: "name", ascending: true)
    }
}
