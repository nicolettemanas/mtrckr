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

/// Defines a `BillEntry` status
///
/// - `.paid`: Status when a `BillEntry` is already paid and a corresponding `Transaction` is already saved
/// - `.unpaid`: Status when a `BillEntry` is still unpaid.
/// - `.skipped`: Status when a `BillEntry` is skipped. Skipped `BillEntries` are not reminded.
enum BillEntryStatus: String {
    case paid, unpaid, skipped
}

/// A Realm `Object` that represents a single schedule under a `Bill`
class BillEntry: Object {

    /// The unique identifier of the `BillEntry`
    @objc dynamic var id: String = ""
    
    /// The amount of the to-be `Transaction` of the `BillEntry`.
    /// This may differ from the amount of the `Bill`
    @objc dynamic var amount: Double = 0.0
    
    /// The date of the payment of the `BillEntry`. The value is `nil`
    /// when the `BillEntry` is unpaid.
    @objc dynamic var datePaid: Date?
    
    /// The due date of the `BillEntry`
    @objc dynamic var dueDate: Date = Date()
    
    /// The status of the `BillEntry` in raw value. See `BillEntryStatus`
    @objc dynamic var status: String = ""
    
    /// The `Bill` where the `BillEntry` is from
    @objc dynamic var bill: Bill?
    
    /// The custom name to be saved when converted to a `Transaction`
    @objc dynamic var customName: String?
    
    /// Reminder custom option after the due date in raw value. See `BillDueReminder`
    @objc dynamic var customPostDueReminder: String?
    
    /// Reminder custom option before the due date in raw value. See `BillDueReminder`
    @objc dynamic var customPreDueReminder: String?
    
    /// The custom `Category` to be saved when converted to a `Transaction`
    @objc dynamic var customCategory: Category?
    
    /// The `Transaction` generated when an entry is paid
    @objc dynamic var transaction: Transaction?

    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - Initializers
    
    /// Creates a `BillEntry` wih the given due date and `Bill`
    ///
    /// - Parameters:
    ///   - dueDate: The due date of the `BillEntry` to be created
    ///   - bill: The `Bill` of the `BillEntry` to be created
    convenience init(dueDate: Date, for bill: Bill) {
        self.init()
        self.id = "\(bill.id)-\(NSUUID().uuidString)"
        self.amount = bill.amount
        self.dueDate = dueDate.start(of: .day)
        self.datePaid = nil
        self.status = BillEntryStatus.unpaid.rawValue
        self.bill = bill
    }

    // MARK: - CRUD
    /// Saves the `BillEntry` to the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to save the `BillEntry` to
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the properties of the `BillEntry` to the values given
    ///
    /// - Parameters:
    ///   - amount: The new amount of the `BillEntry`
    ///   - realm: The `Realm` to save the updated `BillEntry` to
    func update(amount: Double, inRealm realm: Realm) {
        assert(self.status != BillEntryStatus.paid.rawValue)
        guard (BillEntry.with(key: self.id, inRealm: realm) != nil) else { return }

        do {
            try realm.write {
                self.amount = amount
                realm.add(self, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Updates the properties of the `BillEntry` to the values given.
    /// Updates are stored in customed properties to be used if non-nil instead of
    /// corresponding `Bill` properties
    ///
    /// - Parameters:
    ///   - amount: The new amount of the `BillEntry`
    ///   - name: The new name of the `BillEntry`
    ///   - preDueReminder: The customized pre due reminder of the `BillEntry`
    ///   - postDueReminder: The customized post due reminder of the `BillEntry`
    ///   - category: The customized `Category` of the `BillEntry`
    ///   - dueDate: The new due date of the `BillEntry`
    ///   - realm: The `Realm` to save the updated `BillEntry` to
    func update(amount: Double, name: String?, preDueReminder: BillDueReminder?, postDueReminder: BillDueReminder?,
                category: Category?, dueDate: Date, inRealm realm: Realm) {
        guard (BillEntry.with(key: self.id, inRealm: realm) != nil) else { return }
        
        do {
            try realm.write {
                self.amount = amount
                self.customName = name
                self.customPreDueReminder = preDueReminder?.rawValue
                self.customPostDueReminder = postDueReminder?.rawValue
                self.customCategory = category
                self.dueDate = dueDate
                realm.add(self, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the status of `BillEntry` from *paid/skipped* to *unpaid*
    ///
    /// - Parameter realm: The `Realm` to save the updated `BillEntry` to
    func unpay(inRealm realm: Realm) {
        assert(self.bill?.active == true)
        let entry = BillEntry(dueDate: self.dueDate, for: self.bill!)
        self.transaction?.delete(in: realm)
        self.delete(in: realm)
        entry.save(toRealm: realm)
    }
    
    /// Updates the status of `BillEntry` from *unpaid* to *skipped*
    ///
    /// - Parameter realm: The `Realm` to save the updated `BillEntry` to
    func skip(inRealm realm: Realm) {
        guard (BillEntry.with(key: self.id, inRealm: realm) != nil) else { return }
        do {
            try realm.write {
                self.status = BillEntryStatus.skipped.rawValue
                realm.add(self, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the status `BillEntry` from *unpaid/skipped* to *paid*. Creates and
    /// saves the corresponding `Transaction`.
    ///
    /// - Parameters:
    ///   - amount: The amount of the `Transaction` to be saved
    ///   - description: The description of the `Transaction` to be saved
    ///   - account: The `Account` where the `Transaction` is from
    ///   - datePaid: The date of payment of the `BillEntry`
    ///   - realm: The `Realm` where the `Transaction` and `BillEntry` will be saved
    func pay(amount: Double, description: String, fromAccount account: Account,
             datePaid: Date, inRealm realm: Realm) {
        
        guard (BillEntry.with(key: self.id, inRealm: realm) != nil) else { return }
        let trans = generateTransaction(amount      : amount,
                                        description : description,
                                        account     : account,
                                        datePaid    : datePaid,
                                        inRealm     : realm)
        do {
            try realm.write {
                self.amount = amount
                self.datePaid = datePaid
                self.status = BillEntryStatus.paid.rawValue
                self.transaction = trans
                realm.add(self, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Deletes the `BillEntry` from the given `Realm`
    ///
    /// - Parameter realm: The `Realm` to delete the `BillEntry` from
    func delete(in realm: Realm) {
        do {
            try realm.write {
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Fetches the `BillEntry` with the given parameters
    ///
    /// - Parameters:
    ///   - key: The unique ID of the `BillEntry` to be fetched
    ///   - realm: The `Realm` to fetch the `BillEntry` from
    /// - Returns: The fetched `BillEntry`
    static func with(key: String, inRealm realm: Realm) -> BillEntry? {
        return realm.object(ofType: BillEntry.self, forPrimaryKey: key) as BillEntry?
    }

    /// Fetches all `BillEntry`s from the given `Bill` and `Realm`
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch the `BillEntries` from
    ///   - bill: The `Bill` to fetch the `BillEntries` under
    /// - Returns: The `BillEntries` fetched
    static func all(in realm: Realm, for bill: Bill) -> Results<BillEntry> {
        return realm.objects(BillEntry.self).filter("bill.id == %@", bill.id).sorted(byKeyPath: "dueDate")
    }
    
    /// Returns all `BillEntries` of the given `Bill` that is of status `.unpaid`
    ///
    /// - Parameters:
    ///   - realm: The `Realm` to fetch the `BillEntries` from
    ///   - bills: The `Bill` to fetch the `BillEntries` from
    /// - Returns: The unpaid `BillEntries` fetched
    static func allUnpaid(in realm: Realm, for bills: [Bill]) -> Results<BillEntry> {
        return realm.objects(BillEntry.self)
            .filter("bill in %@", bills)
            .filter("status == %@", BillEntryStatus.unpaid.rawValue)
            .sorted(byKeyPath: "dueDate", ascending: true)
    }
    
    /// Returns all `BillEntries` that is of status `.unpaid`
    ///
    /// - Parameter realm: The `Realm` to fetch the `BillEntries` from
    /// - Returns: The unpaid `BillEntries` fetched
    static func allUnpaid(in realm: Realm) -> Results<BillEntry> {
        return realm.objects(BillEntry.self)
            .filter("status == %@", BillEntryStatus.unpaid.rawValue)
            .sorted(byKeyPath: "dueDate")
    }

    /// :nodoc:
    private func generateTransaction(amount: Double, description: String,
                                     account: Account, datePaid: Date, inRealm realm: Realm) -> Transaction {
        
        assert(self.bill?.active == true)
        let trans = Transaction(type          : .expense,
                                name          : self.bill!.name,
                                image         : nil,
                                description   : description,
                                amount        : amount,
                                category      : self.bill?.category,
                                from          : account,
                                to            : account,
                                date          : datePaid)
        trans.billEntry = self
        return trans
    }
}
