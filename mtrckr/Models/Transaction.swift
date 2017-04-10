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

enum TransactionType: String {
    case expense, income, transfer
}

class Transaction: Object {

    dynamic var id: String = ""
    dynamic var type: String = ""
    dynamic var name: String = ""
    dynamic var image: String?
    dynamic var desc: String?
    dynamic var amount: Double = 0.0
    dynamic var transactionDate: Date = Date()
    
    dynamic var fromAccount: Account?
    dynamic var toAccount: Account?
    dynamic var category: Category?
    dynamic var user: User?
    dynamic var billEntry: BillEntry?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    init(type: TransactionType, name: String, image: String?, description: String?, amount: Double,
        category: Category?, from fromAccount: Account, to toAccount: Account, date: Date) {
        
        super.init()
        self.id = "TRANS-\(fromAccount.user!.id)-\(UUID().uuidString)"
        self.type = type.rawValue
        self.name = name
        self.image = image
        self.desc = description
        self.amount = amount
        self.category = category
        self.fromAccount = fromAccount
        self.toAccount = toAccount
        self.transactionDate = date
        self.user = fromAccount.user
    }
    
    // MARK: Required methods
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init() {
        super.init()
    }
    
    // MARK: CRUD operations
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                self.willSave()
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func update(type: TransactionType, name: String, image: String?, description: String?, amount: Double,
                category: Category?, from fromAccount: Account, to toAccount: Account, date: Date, inRealm realm: Realm) {
        guard let _ = Transaction.with(key: self.id, inRealm: realm) else { return }
        
        do {
            try realm.write {
                let newTransaction = Transaction(type: type, name: name, image: image, description: description, amount: amount,
                                                 category: category, from: fromAccount, to: toAccount, date: date)
                self.willDelete(inRealm: realm)
                realm.delete(self)
                
                newTransaction.willSave()
                realm.add(newTransaction)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
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
    
    static func with(key: String, inRealm realm: Realm) -> Transaction? {
        return realm.object(ofType: Transaction.self, forPrimaryKey: key) as Transaction?
    }
    
    static func all(in realm: Realm, fromAccount account: Account) -> Results<Transaction> {
        return realm.objects(Transaction.self).filter("fromAccount.id == %@", account.id).sorted(byKeyPath: "transactionDate")
    }
    
    static func all(in realm: Realm, underCategory category: Category) -> Results<Transaction> {
        return realm.objects(Transaction.self).filter("category.id == %@", category.id).sorted(byKeyPath: "transactionDate")
    }
    
    static func all(in realm: Realm, underBill bill: Bill) -> Results<Transaction> {
        return realm.objects(Transaction.self).filter("billEntry.bill.id == %@", bill.id).sorted(byKeyPath: "transactionDate")
    }
    
    //MARK: - associated account methods
    func willDelete(inRealm realm: Realm) {
        if self.type == TransactionType.expense.rawValue {
            self.toAccount?.currentAmount += self.amount
            self.toAccount?.totalExpenses -= self.amount
        }else if self.type == TransactionType.income.rawValue {
            self.toAccount?.currentAmount -= self.amount
            self.toAccount?.totalIncome -= self.amount
        }else {
            self.fromAccount?.currentAmount += self.amount
            self.toAccount?.currentAmount -= self.amount
        }
        
        guard let entry = self.billEntry else { return }
        let entryCopy = BillEntry(dueDate: entry.dueDate, for: entry.bill!)
        realm.delete(entry)
        realm.add(entryCopy)
    }
    
    func willSave() {
        if self.type == TransactionType.expense.rawValue {
            assert(self.toAccount == self.fromAccount)
            assert(self.type == self.category?.type)
            self.toAccount?.currentAmount -= self.amount
            self.toAccount?.totalExpenses += self.amount
        }else if self.type == TransactionType.income.rawValue {
            assert(self.toAccount == self.fromAccount)
            assert(self.type == self.category?.type)
            self.toAccount?.currentAmount += self.amount
            self.toAccount?.totalIncome += self.amount
        }else {
            assert(self.toAccount != self.fromAccount)
            assert(self.category == nil)
            self.fromAccount?.currentAmount -= self.amount
            self.toAccount?.currentAmount += self.amount
        }
    }
}
