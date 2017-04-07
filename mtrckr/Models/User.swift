//
//  User.swift
//  mtrckr
//
//  Created by User on 4/6/17.
//
//

import UIKit
import RealmSwift
import Realm

class User: Object {
    
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var email: String = ""
    dynamic var image: String = ""
    dynamic var currency: Currency?
    
    var accounts = LinkingObjects(fromType: Account.self, property: "user")
    let bills = LinkingObjects(fromType: Bill.self, property: "user")
    let customCategories = LinkingObjects(fromType: Category.self, property: "user")
    
//    let budgets = LinkingObjects(fromType: Budget.self, property: "user")
//    let transactions = LinkingObjects(fromType: Transaction.self, property: "user")
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: String, name: String, email: String, image: String, currency: Currency) {
        self.init()
        self.id = id
        self.name = name
        self.email = email
        self.image = image
        self.currency = currency
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
    
    func update(to user: User, in realm: Realm) {
        guard self.id == user.id else { return }
        
        do {
            try realm.write {
                realm.add(user, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func delete(in realm: Realm) {
        do {
            try realm.write {
                realm.delete(self.customCategories)
                realm.delete(self.bills)
                realm.delete(self.accounts)
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    static func with(key: String, inRealm realm: Realm) -> User? {
        return realm.object(ofType: User.self, forPrimaryKey: key) as User?
    }
    
    static func all(in realm: Realm) -> Results<User> {
        return realm.objects(User.self).sorted(byKeyPath: "name")
    }
}
