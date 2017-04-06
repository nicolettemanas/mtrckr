//
//  Account.swift
//  MoneyTracker
//
//  Created by User on 2/25/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Account: Object {

    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var type: AccountType?
    dynamic var initialAmount: Double = 0.0
    dynamic var currentAmount: Double = 0.0
    dynamic var totalExpenses: Double = 0.0
    dynamic var totalIncome: Double = 0.0
    dynamic var color: String = ""
    dynamic var dateOpened: Date = Date()
    dynamic var user: User?
    
//    var transactionsToSelf = LinkingObjects(fromType: Transaction.self, property: "toAccnt")
//    var transactionsFromSelf = LinkingObjects(fromType: Transaction.self, property: "fromAccnt")
//    var budgetsAffected = LinkingObjects(fromType: Budget.self, property: "forAccounts")
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
//    convenience init(accountId: String, name: String, type: Account, initialAmount: ) {
//        self.init()
//        self.typeId = typeId
//        self.name = name
//        self.icon = icon
//    }
    
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
    
    func update(name: String, type: AccountType, initialAmount: Double, color: String, dateOpened: Date, in realm: Realm) {
        do {
            try realm.write {
                self.name = name
                self.type = type
                self.initialAmount = initialAmount
                self.color = color
                self.dateOpened = dateOpened
                realm.add(self, update: true)
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
    
    static func with(key: String, inRealm realm: Realm) -> Account? {
        return realm.object(ofType: Account.self, forPrimaryKey: key) as Account?
    }
    
    static func all(in realm: Realm, ofUser user: User) -> Results<Account> {
        return realm.objects(Account.self).filter("id == %@", user.id)
    }
}
