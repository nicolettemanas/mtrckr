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

/// A Realm `Object` that represents a Currency
class Currency: Object {
    
    // MARK: - Properties

    /// The unique identifier of the `Currency`
    dynamic var id: String! = ""
    
    /// The iso code of the `Currency`
    dynamic var isoCode: String! = ""
    
    /// The symbol of the `Currency`
    dynamic var symbol: String! = ""
    
    /// The state of the `Currency`
    dynamic var state: String! = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - Initializers
    
    /// Creates a `Currency` with the given values
    ///
    /// - Parameters:
    ///   - id: The id of the `Currency`
    ///   - isoCode: The iso code of the `Currency`
    ///   - symbol: The symbol of the `Currency`
    ///   - state: The state of the `Currency`
    convenience init(id: String, isoCode: String, symbol: String, state: String) {
        self.init()
        self.id = id
        self.isoCode = isoCode
        self.symbol = symbol
        self.state = state
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
    
    /// Saves the `Currency` to the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to save the `Currency` to
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the `Currency` with the given instance
    ///
    /// - Parameters:
    ///   - updatedCurrency: The updated `Currency`
    ///   - realm: The `Realm` to save the updated `Currency`
    func update(to updatedCurrency: Currency, in realm: Realm) {
        guard self.id == updatedCurrency.id else { return }

        do {
            try realm.write {
                realm.add(updatedCurrency, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Deletes the `Currency` from the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to delete the `Currency` from
    func delete(in realm: Realm) {
        do {
            try realm.write {
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Returns the `Currency` with the given iso code
    ///
    /// - Parameters:
    ///   - isoCode: The iso code of the `Currency` to be fetched
    ///   - realm: The `Realm` to fetch the `Currency` from
    /// - Returns: The fetched `Currency`
    static func with(isoCode: String, inRealm realm: Realm) -> Currency? {
        return realm.objects(Currency.self)
            .filter("isoCode == %@", isoCode)
            .first as Currency?
    }
    
    /// Returns the `Currency` with the given id
    ///
    /// - Parameters:
    ///   - key: The ID of the `Currency` to be fetched
    ///   - realm: The `Realm` to fetch the `Currency` from
    /// - Returns: The fetched `Currency`
    static func with(key: String, inRealm realm: Realm) -> Currency? {
        return realm.object(ofType: Currency.self, forPrimaryKey: key) as Currency?
    }

    /// Returns all saved `Currencies` from the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to fetch the `Currencies` from
    /// - Returns: The `Currencies` fetched
    static func all(in realm: Realm) -> Results<Currency> {
        return realm.objects(Currency.self).sorted(byKeyPath: "isoCode", ascending: true)
    }
}
