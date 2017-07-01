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

/// A Realm `Object` that represents a collection of transactions in a separate pool of savings.
class Account: Object {

    // MARK: - Properties
    /// The unique identifier of the Account
    dynamic var id: String = ""
    
    /// The name of the account
    dynamic var name: String = ""
    
    /// The type of the account. See `AccountType`
    dynamic var type: AccountType?
    
    /// The initial amount of the account when created
    dynamic var initialAmount: Double = 0.0
    
    /// The current acmount in the account
    dynamic var currentAmount: Double = 0.0
    
    /// The overall total of exptenses transactions
    dynamic var totalExpenses: Double = 0.0
    
    /// The overall total of income transactions
    dynamic var totalIncome: Double = 0.0
    
    /// The preferred color of the account
    dynamic var color: String = ""
    
    /// The date the account opened
    dynamic var dateOpened: Date = Date()

    /// Collection of transactions with the destination account is the instance account
    var transactionsToSelf = LinkingObjects(fromType: Transaction.self, property: "toAccount")
    
    /// Collection of transactions with source account is the instance account
    var transactionsFromSelf = LinkingObjects(fromType: Transaction.self, property: "fromAccount")
//    var budgetsAffected = LinkingObjects(fromType: Budget.self, property: "forAccounts")

    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - CRUD
    /// Saves the Account to the realm given
    ///
    /// - Parameter realm: The realm to save the account to
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the account to the given instance.
    /// Update will fail if the accounts do not have the same id.
    ///
    /// - Parameters:
    ///   - account: The updated account
    ///   - realm: The realm to save the account to
    func update(to account: Account, in realm: Realm) {
        guard self.id == account.id else { return }

        do {
            try realm.write {
                realm.add(account, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the account properties to the given values
    /// Update will fail if the accounts do not have the same id.
    ///
    /// - Parameters:
    ///   - name: The new name of the account
    ///   - type: The new type of the account
    ///   - initialAmount: The new initial amount of the account
    ///   - color: The new preferrec color of the account
    ///   - dateOpened: The new date opened of the account
    ///   - realm: The realm to save the updated account to
    func update(name: String, type: AccountType, initialAmount: Double,
                color: String, dateOpened: Date, in realm: Realm) {
        guard (Account.with(key: self.id, inRealm: realm) != nil) else { return }
        do {
            try realm.write {
                self.name = name
                self.type = type
                self.color = color
                self.dateOpened = dateOpened

                let prevCurrentAmount = self.currentAmount
                self.currentAmount = prevCurrentAmount - self.initialAmount + initialAmount
                self.initialAmount = initialAmount

                realm.add(self, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Deletes the account from the given realm.
    /// Deletes other associated models.
    ///
    /// - Parameter realm: The realm to delete the account from
    func delete(in realm: Realm) {
        do {
            try realm.write {
                realm.delete(self.transactionsToSelf)
                realm.delete(self.transactionsFromSelf)
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Fetches the account with the given parameters
    ///
    /// - Parameters:
    ///   - key: The unique ID of the account to fetch
    ///   - realm: The realm to fetch the account from
    /// - Returns: The account fetched
    static func with(key: String, inRealm realm: Realm) -> Account? {
        return realm.object(ofType: Account.self, forPrimaryKey: key) as Account?
    }
    
    /// Fetches all the account from the given realm
    ///
    /// - Parameter realm: The realm to fetch all the accounts from
    /// - Returns: All the accounts found in the given realm
    static func all(in realm: Realm) -> Results<Account> {
        return realm.objects(Account.self).sorted(byKeyPath: "name")
    }
}
