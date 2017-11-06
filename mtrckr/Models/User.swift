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

/// A Realm `Object` that represents a single User in the application
class User: Object {

    // MARK: - Properties
    /// The unique identifier of the `User`
    @objc dynamic var id: String = ""
    
    /// The name of the `User`
    @objc dynamic var name: String = ""
    
    /// The email of the `User`
    @objc dynamic var email: String = ""
    
    /// The image of the `User`
    @objc dynamic var image: String = ""
    
    /// The `Currency` currently used by the `User`
    @objc dynamic var currency: Currency?

    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - Initializers
    /// Creates a user with the given values
    ///
    /// - Parameters:
    ///   - id: A unique ID of the `User`
    ///   - name: The name of the `User`
    ///   - email: The email of the `User`
    ///   - image: The image path of the `User`
    ///   - currency: The `Currency` that will be used by the `User`
    convenience init(id: String, name: String, email: String, image: String, currency: Currency) {
        self.init()
        self.id = id
        self.name = name
        self.email = email
        self.image = image
        self.currency = currency
    }

    // MARK: Required methods
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

    // MARK: CRUD
    
    /// Saves the `User` to the fiven `Realm`
    ///
    /// - Parameter realm: The `Realm` to save the `User` to
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the `User` to the given `User` instance
    ///
    /// - Parameters:
    ///   - user: The updated `User`
    ///   - realm: The `Realm` to save the updated `User` to
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

    /// Deletes the `User` from the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to delete the `User` from
    func delete(in realm: Realm) {
        do {
            try realm.write {
                // TODO: Why are these commented out?
//                realm.delete(self.customCategories)
//                realm.delete(self.bills)
//                realm.delete(self.accounts)
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Fetch the `User` with the given ID
    ///
    /// - Parameters:
    ///   - key: The unique ID of the `User` to be fetched
    ///   - realm: The `Realm` to fetch the `User` from
    /// - Returns: The fetched `User`
    static func with(key: String, inRealm realm: Realm) -> User? {
        return realm.object(ofType: User.self, forPrimaryKey: key) as User?
    }

    /// Fetch all the `User`s in the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to fetch the `User` from
    /// - Returns: The fetched `User`
    static func all(in realm: Realm) -> Results<User> {
        return realm.objects(User.self).sorted(byKeyPath: "name")
    }
}
