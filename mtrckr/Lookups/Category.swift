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

/// The types of `Categories`
///
/// - `.expense`: A `Category` type tagged as an expense
/// - `.income`: A `Category` type tagged as an income
enum CategoryType: String {
    case expense, income
}

/// A Realm `Object` that represents a single `Transaction` category
class Category: Object {

    /// The unique identifier of the `Category`
    dynamic var id: String = ""
    
    /// The type of `Category` in raw value
    dynamic var type: String = "expense"
    
    /// The name of the `Category`
    dynamic var name: String = ""
    
    /// The icon url path of the `Category`
    dynamic var icon: String = "decault.jpg"
    
    /// A flag indicating whether a `Category` is a customed category or not
    dynamic var isCustomized: Bool = false
    
    /// The color of the `Category`
    dynamic var color: String = ""

    /// The `Transaction`s listed under the `Category`
    let transactions = LinkingObjects(fromType: Transaction.self, property: "category")
//    let budgetsAffected = LinkingObjects(fromType: Budget.self, property: "forCategories")
    
    /// The `Bill`s listed under the `Category`
    let bills = LinkingObjects(fromType: Bill.self, property: "category")

    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - Initializers
    
    /// Creates a `Category` with the given values
    ///
    /// - Parameters:
    ///   - type: The type of the `Category` to be created
    ///   - name: The name of the `Category` to be created
    ///   - icon: The icon path url of the `Category` to be created
    ///   - color: The color of the `Category` to be created
    convenience init(type: CategoryType, name: String, icon: String, color: String) {
        self.init()
        self.id = "CAT-\(UUID().uuidString)"
        self.type = type.rawValue
        self.name = name
        self.icon = icon
        self.isCustomized = true
        self.color = color
    }

    /// Creates a `Category` with the given values
    ///
    /// - Parameters:
    ///   - id: The id of the `Category` to be created
    ///   - type: The type of the `Category` to be created
    ///   - name: The name of the `Category` to be created
    ///   - icon: The icon path url of the `Category` to be created
    ///   - color: The color of the `Category` to be created
    convenience init(id: String, type: CategoryType, name: String, icon: String, color: String) {
        self.init()
        self.id = id
        self.type = type.rawValue
        self.name = name
        self.icon = icon
        self.color = color
    }

    /// :nodoc:
    required init() {
        super.init()
    }

    /// :nodoc:
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    /// :nodoc:
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    // MARK: - CRUD
    
    /// Saves the `Category` to the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to save the `Category` to
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the `Category` to the instance given
    ///
    /// - Parameters:
    ///   - updatedCategory: The updated `Category`
    ///   - realm: The `Realm` to save the updated `Category`
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

    /// Deletes the `Category` from the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to delete the `Category` from
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

    /// Returns the `Category` with the given ID
    ///
    /// - Parameters:
    ///   - key: The id of the `Category` to fetch
    ///   - realm: The `Realm` to fetch the `Category` from
    /// - Returns: The `Category` fetched
    static func with(key: String, inRealm realm: Realm) -> Category? {
        return realm.object(ofType: Category.self, forPrimaryKey: key) as Category?
    }
    
    /// Returns all `Categories` found in the given `Realm`
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch the `Categories` from
    ///   - customized: Flag whether to fetch customed `Categories` or not
    /// - Returns: The `Categories` fetched
    static func all(in realm: Realm, customized: Bool) -> Results<Category> {
        return realm.objects(Category.self)
            .filter(NSPredicate(format: "isCustomized == \(customized)"))
            .sorted(byKeyPath: "name", ascending: true)
    }

    /// Returns all `Categories` found in the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to fetch the `Categories` from
    /// - Returns: The `Categories` fetched
    static func all(in realm: Realm) -> Results<Category> {
        return realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
    }

    /// Returns all `Categories` found in the given `Realm`
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch the `Categories` from
    ///   - type: The `Category` type to filter
    /// - Returns: The `Categories` fetched
    static func all(in realm: Realm, ofType type: CategoryType) -> Results<Category> {
        return realm.objects(Category.self)
            .filter(NSPredicate(format: "type == %@", type.rawValue))
            .sorted(byKeyPath: "name", ascending: true)
    }
}
