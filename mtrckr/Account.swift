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

    var transactionsToSelf = LinkingObjects(fromType: Transaction.self, property: "toAccount")
    var transactionsFromSelf = LinkingObjects(fromType: Transaction.self, property: "fromAccount")
//    var budgetsAffected = LinkingObjects(fromType: Budget.self, property: "forAccounts")

    override static func primaryKey() -> String? {
        return "id"
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

    static func with(key: String, inRealm realm: Realm) -> Account? {
        return realm.object(ofType: Account.self, forPrimaryKey: key) as Account?
    }

    static func all(in realm: Realm, ofUser user: User) -> Results<Account> {
        return realm.objects(Account.self).filter("user.id == %@", user.id).sorted(byKeyPath: "name")
    }
}
