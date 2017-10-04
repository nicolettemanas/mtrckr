//
//  Transaction.swift
//  mtrckr
//
//  Created by User on 4/10/17.
//
//

import UIKit
import RealmSwift
import Realm
import DateToolsSwift

/// Types of `Transaction`s
///
/// - `.expense`: Defines a `Transaction` that subtracts an amount (cost) from the `Account`
/// - `.income`: Defines a `Transaction` that adds an amount to the `Account`
/// - `.transfer`: Defines a `Transaction` that subtracts an amount from an `Account` and adds it to different `Account`
enum TransactionType: String {
    case expense, income, transfer
}

/// A Realm `Object` that represents a single `Transaction` record
class Transaction: Object {
    
    // MARK: - Properties

    /// The unique identifier of the `Transaction`
    dynamic var id: String = ""
    
    /// The type of the `Transaction` in raw value. See `TransactionType`.
    dynamic var type: String = ""
    
    /// The name or title of the `Transaction`
    dynamic var name: String = ""
    
    /// The image of the `Transaction`
    dynamic var image: String?
    
    /// The description details of the `Transaction`
    dynamic var desc: String?
    
    /// The cost or amount of the `Transaction`
    dynamic var amount: Double = 0.0
    
    /// The date of the `Transaction`
    dynamic var transactionDate: Date = Date()

    /// The `Account` from where the `Transaction` is recorded
    dynamic var fromAccount: Account?
    
    /// The `Account` to where the `Transaction` is recorded. If the `Transaction` is of type `.expense`
    /// or `.income`, `toAccount` and `fromAccount` is of the same value.
    dynamic var toAccount: Account?
    
    /// The `Category` of the `Transaction`. See `Category`.
    dynamic var category: Category?

    /// The `BillEntry` associated with the `Transaction` if available
    dynamic var billEntry: BillEntry?

    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - Initializers
    /// Creates a `Transaction` with the given properties
    ///
    /// - Parameters:
    ///   - type: The type of the `Transaction` to be created
    ///   - name: The name or title of the `Transaction` to be created
    ///   - image: The image path of the `Transaction` to be created
    ///   - description: The description of the `Transaction` to be created
    ///   - amount: The amount or cost of the `Transaction` to be created
    ///   - category: The category of the `Transaction` to be created
    ///   - fromAccount: The `Account` where the `Transaction` is recorded. If the `Transaction` is of type `.transfer`: The `Account`
    ///     where the amount is taken from.
    ///   - toAccount: If the `Transaction` is of type `.expense` or `.income`: The `Account` where the `Transaction` is recorded
    ///     If the `Transaction` is of type `.transfer`: The `Account` there the amount is transfered to.
    ///   - date: The date of the `Transaction` to be created
    init(type: TransactionType, name: String, image: String?, description: String?, amount: Double,
         category: Category?, from fromAccount: Account, to toAccount: Account, date: Date) {

        super.init()
        self.id = "TRANS-\(UUID().uuidString)"
        self.type = type.rawValue
        self.name = name
        self.image = image
        self.desc = description
        self.amount = amount
        self.category = category
        self.fromAccount = fromAccount
        self.toAccount = toAccount
        self.transactionDate = date
    }

    // MARK: - Required methods
    /// :nodoc:
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    /// :nodoc:
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    /// :nodoc:
    required init() {
        super.init()
    }

    // MARK: - CRUD
    
    /// Saves the `Transaction` to the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to save the `Transaction` to
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                self.willSave()
                print("Transaction: \(self.id) \(self.transactionDate)")
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Updates the `Transaction` property values to the given values
    ///
    /// - Parameters:
    ///   - type: The new type of the `Transaction`
    ///   - name: The new title or name of the `Transaction`
    ///   - image: The new image path of the `Transaction`
    ///   - description: The new description of the `Transaction`
    ///   - amount: The new amount of the `Transaction`
    ///   - category: The new `Category` of the `Transaction`
    ///   - fromAccount: The new `Account` source of the `Transaction`
    ///   - toAccount: The new `Account` destination of the `Transaction`
    ///   - date: The new `Transaction` date
    ///   - realm: The `Realm` where the updated will be saved
    func update(type: TransactionType, name: String, image: String?, description: String?,
                amount: Double, category: Category?, from fromAccount: Account, to toAccount: Account,
                date: Date, inRealm realm: Realm) {

        if Transaction.with(key: self.id, inRealm: realm) == nil { return }

        do {
            try realm.write {
                let newTransaction = Transaction(type: type, name: name, image: image, description: description,
                                                 amount: amount, category: category, from: fromAccount,
                                                 to: toAccount, date: date)
                self.willDelete(inRealm: realm)
                realm.delete(self)

                newTransaction.willSave()
                realm.add(newTransaction)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Updates the `Transaction` to the given `Transaction`
    ///
    /// - Parameters:
    ///   - transaction: The updated `Transaction`
    ///   - realm: The `Realm` where the updated will be saved
    func updateTo(transaction: Transaction, inRealm realm: Realm) {
        if Transaction.with(key: self.id, inRealm: realm) == nil { return }
        if self.id != transaction.id { fatalError("Trying to update the wrong Transaction.") }
        do {
            try realm.write {
                self.willDelete(inRealm: realm)
                realm.delete(self)
                
                transaction.willSave()
                realm.add(transaction)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Deletes a `Transaction` and its associated models
    ///
    /// - Parameter realm: The `Realm` to delete the `Transaction` from
    func delete(in realm: Realm) {
        do {
            try realm.write {
                self.willDelete(inRealm: realm)
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Returns the `Transaction` with the given unique ID found in the given `Realm
    ///
    /// - Parameters:
    ///   - key: The unique ID of the `Transaction` to be fetched
    ///   - realm: The `Realm` to fetch the `Transaction` from
    /// - Returns: The fetched `Transaction`
    static func with(key: String, inRealm realm: Realm) -> Transaction? {
        return realm.object(ofType: Transaction.self, forPrimaryKey: key) as Transaction?
    }
 
    /// Returns all `Transaction`s from `Account` under given `Realm
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch `Transaction`s from
    ///   - account: The `Account` to fetch the `Transaction`s from
    /// - Returns: The `Transaction`s fetched
    static func all(in realm: Realm, fromAccount account: Account) -> Results<Transaction> {
        return realm.objects(Transaction.self)
            .filter("fromAccount.id == %@", account.id)
            .sorted(byKeyPath: "transactionDate", ascending: false)
    }
    
    /// Returns all `Transactions` from the given `Accounts`
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch the `Transactions` from
    ///   - accounts: The `Accounts` to fetch the `Transactions` from
    /// - Returns: The `Transactions` fetched
    static func all(in realm: Realm, fromAccounts accounts: [Account]) -> Results<Transaction> {
        return realm.objects(Transaction.self)
            .filter("fromAccount in %@", accounts)
            .sorted(byKeyPath: "transactionDate", ascending: false)
    }

    /// Returns all `Transaction`s with the given `Category`
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch the `Transaction`s from
    ///   - category: The `Category` to filter the `Transaction` with
    /// - Returns: The `Transaction`s fetched
    static func all(in realm: Realm, underCategory category: Category) -> Results<Transaction> {
        return realm.objects(Transaction.self)
            .filter("category.id == %@", category.id)
            .sorted(byKeyPath: "transactionDate", ascending: false)
    }

    /// Returns all `Transaction`s associated with the given `Bill`
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch the `Transaction`s from
    ///   - bill: The `Bill` associated to the `Transaction`s to be fetched
    /// - Returns: The `Transaction`s fetched
    static func all(in realm: Realm, underBill bill: Bill) -> Results<Transaction> {
        return realm.objects(Transaction.self)
            .filter("billEntry.bill.id == %@", bill.id)
            .sorted(byKeyPath: "transactionDate", ascending: false)
    }
    
    /// Returns all `Transactions` from the given date
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch the `Transactions` from
    ///   - date: The date filter
    /// - Returns: The `Transactions` fetched
    static func all(in realm: Realm, onDate date: Date) -> Results<Transaction> {
        return realm.objects(Transaction.self)
            .filter("transactionDate >= %@ AND transactionDate =< %@", date.start(of: .day), date.end(of: .day))
            .sorted(byKeyPath: "transactionDate", ascending: false)
    }
    
    /// Returns all `Transactions` from the given date period under the `Accounts` given
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch the `Transactions` from
    ///   - startDate: The start date filter
    ///   - endDate: The end date filter
    ///   - accounts: The `Accounts` filter
    /// - Returns: The `Transactions` fetched
    static func all(in realm: Realm, between startDate: Date, and endDate: Date,
                    inAccounts accounts: [Account]) -> Results<Transaction> {
        if accounts.count == 0 {
            return realm.objects(Transaction.self)
                .filter("transactionDate >= %@ AND transactionDate =< %@", startDate.start(of: .day), endDate.end(of: .day))
                .sorted(byKeyPath: "transactionDate", ascending: false)
        } else {
            return realm.objects(Transaction.self)
                .filter("transactionDate >= %@ AND transactionDate =< %@", startDate.start(of: .day), endDate.end(of: .day))
                .filter("fromAccount in %@", accounts)
                .sorted(byKeyPath: "transactionDate", ascending: false)
        }
    }

    // MARK: - associated account methods
    /// :nodoc:
    private func willDelete(inRealm realm: Realm) {
        if self.type == TransactionType.expense.rawValue {
            self.toAccount?.currentAmount += self.amount
            self.toAccount?.totalExpenses -= self.amount
        } else if self.type == TransactionType.income.rawValue {
            self.toAccount?.currentAmount -= self.amount
            self.toAccount?.totalIncome -= self.amount
        } else {
            self.fromAccount?.currentAmount += self.amount
            self.toAccount?.currentAmount -= self.amount
        }

        guard let entry = self.billEntry else { return }
        let entryCopy = BillEntry(dueDate: entry.dueDate, for: entry.bill!)
        realm.delete(entry)
        realm.add(entryCopy)
    }

    /// :nodoc:
    private func willSave() {
        if self.type == TransactionType.expense.rawValue {
            assert(self.toAccount == self.fromAccount)
            assert(self.type == self.category?.type)
            self.toAccount?.currentAmount -= self.amount
            self.toAccount?.totalExpenses += self.amount
        } else if self.type == TransactionType.income.rawValue {
            assert(self.toAccount == self.fromAccount)
            assert(self.type == self.category?.type)
            self.toAccount?.currentAmount += self.amount
            self.toAccount?.totalIncome += self.amount
        } else {
            assert(self.toAccount != self.fromAccount)
            assert(self.category == nil)
            self.fromAccount?.currentAmount -= self.amount
            self.toAccount?.currentAmount += self.amount
        }
    }
}
