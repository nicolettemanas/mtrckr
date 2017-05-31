//
//  TransactionCategory.swift
//  MoneyTracker
//
//  Created by User on 2/25/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

enum CategoryType: String {
    case expense, income
}

class Category: Object {

    dynamic var id: String = ""
    dynamic var type: String = "expense"
    dynamic var name: String = ""
    dynamic var icon: String = "decault.jpg"
    dynamic var isCustomized: Bool = false

    let transactions = LinkingObjects(fromType: Transaction.self, property: "category")
//    let budgetsAffected = LinkingObjects(fromType: Budget.self, property: "forCategories")
    let bills = LinkingObjects(fromType: Bill.self, property: "category")

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(type: CategoryType, name: String, icon: String) {
        self.init()
        self.id = "CAT-\(UUID().uuidString)"
        self.type = type.rawValue
        self.name = name
        self.icon = icon
        self.isCustomized = true
    }

    convenience init(id: String, type: CategoryType, name: String, icon: String) {
        self.init()
        self.id = id
        self.type = type.rawValue
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

    func update(to updatedCategory: Category, in realm: Realm) {
        guard self.id == updatedCategory.id else { return }

        do {
            try realm.write {
                realm.add(updatedCategory, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    func delete(in realm: Realm) {
        for t in self.transactions { t.delete(in: realm) }
        for b in self.bills { b.delete(in: realm) }

        do {
            try realm.write {
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    static func with(key: String, inRealm realm: Realm) -> Category? {
        return realm.object(ofType: Category.self, forPrimaryKey: key) as Category?
    }

    static func all(in realm: Realm, customized: Bool) -> Results<Category> {
        return realm.objects(Category.self)
            .filter(NSPredicate(format: "isCustomized == \(customized)"))
            .sorted(byKeyPath: "name", ascending: true)
    }

    static func all(in realm: Realm) -> Results<Category> {
        return realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
    }

    static func all(in realm: Realm, ofType type: CategoryType) -> Results<Category> {
        return realm.objects(Category.self)
            .filter(NSPredicate(format: "type == %@", type.rawValue))
            .sorted(byKeyPath: "name", ascending: true)
    }
}
