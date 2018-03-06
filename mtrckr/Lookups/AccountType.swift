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

/// A Realm `Object` that represents a type of an `Account`
class AccountType: Object {

    /// The unique identifier of the `AccountType`
    @objc dynamic var typeId: Int = 0

    /// The name of the `AccountType`
    @objc dynamic var name: String = ""

    /// The icon path url of the `AccountType`
    @objc dynamic var icon: String = ""
//    let accounts = LinkingObjects(fromType: Account.self, property: "type")

    override static func primaryKey() -> String? {
        return "typeId"
    }

    // MARK: - Initializers

    /// Creates an `AccountType`
    ///
    /// - Parameters:
    ///   - typeId: The unique id of the `AccountType` to be created
    ///   - name: The name of the `AccountType` to be created
    ///   - icon: The icon url path of the `AccountType` to be created
    convenience init(typeId: Int, name: String, icon: String) {
        self.init()
        self.typeId = typeId
        self.name = name
        self.icon = icon
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

    /// Saves the `AccountType` to the `Realm` given
    ///
    /// - Parameter realm: The `Realm` to save the `AccountType` to
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the `AccountType` to the given instance
    ///
    /// - Parameters:
    ///   - updatedAccountType: The updated instance of `AccountType`
    ///   - realm: The `Realm` to save the updated `AccountType` to
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

    /// Deletes the `AccountType` from the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to delete the `AccountType` from
    func delete(in realm: Realm) {
        do {
            try realm.write {
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Returns the `AccountType` with the given key
    ///
    /// - Parameters:
    ///   - key: The unique ID of the `AccountType` to be fetched
    ///   - realm: The `Realm` to fetch `AccountType` from
    /// - Returns: The `AccountType` fetched
    static func with(key: Int, inRealm realm: Realm) -> AccountType? {
        return realm.object(ofType: AccountType.self, forPrimaryKey: key) as AccountType?
    }

    /// Returns all the `AccountType` from the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to fetch the `AccountType`s from
    /// - Returns: The fetched `AccountType`s
    static func all(in realm: Realm) -> Results<AccountType> {
        return realm.objects(AccountType.self).sorted(byKeyPath: "name", ascending: true)
    }
}
