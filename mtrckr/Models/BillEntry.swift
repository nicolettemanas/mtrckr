//
//  BillEntry.swift
//  mtrckr
//
//  Created by User on 4/8/17.
//
//

import UIKit
import RealmSwift
import Realm

enum BillEntryStatus: String {
    case paid, unpaid, skipped
}

class BillEntry: Object {

    dynamic var id: String = ""
    dynamic var amount: Double = 0.0
    dynamic var datePaid: Date?
    dynamic var dueDate: Date = Date()
    dynamic var status: String = ""
    dynamic var bill: Bill?
//    dynamic var transaction: Transaction?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(dueDate: Date, for bill: Bill) {
        self.init()
        self.id = "\(bill.id)-\(NSUUID().uuidString)"
        self.amount = bill.amount
        self.dueDate = dueDate
        self.datePaid = nil
        self.status = BillEntryStatus.unpaid.rawValue
        self.bill = bill
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
    
    func update(amount: Double, inRealm realm: Realm) {
        guard let _ = BillEntry.with(key: self.id, inRealm: realm) else { return }
        
        do {
            try realm.write {
                self.amount = amount
                realm.add(self, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func pay(amount: Double, description: String, fromAccount: Account, datePaid: Date, inRealm realm: Realm) {
        guard let _ = BillEntry.with(key: self.id, inRealm: realm) else { return }
        do {
            try realm.write {
                
                //TODO: Make a transaction and save
                self.amount = amount
                self.datePaid = datePaid
                self.status = BillEntryStatus.paid.rawValue
                realm.add(self, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func skip(inRealm realm: Realm) {
        guard let _ = BillEntry.with(key: self.id, inRealm: realm) else { return }
        do {
            try realm.write {
                
                //TODO: Make a transaction and save
                self.status = BillEntryStatus.skipped.rawValue
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
    
    static func with(key: String, inRealm realm: Realm) -> BillEntry? {
        return realm.object(ofType: BillEntry.self, forPrimaryKey: key) as BillEntry?
    }
    
    static func all(in realm: Realm, for bill: Bill) -> Results<BillEntry> {
        return realm.objects(BillEntry.self).filter("bill.id == %@", bill.id).sorted(byKeyPath: "dueDate")
    }

}