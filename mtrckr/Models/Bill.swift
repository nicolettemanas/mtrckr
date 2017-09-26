//
//  Bill.swift
//  mtrckr
//
//  Created by User on 4/7/17.
//
//

import UIKit
import RealmSwift
import Realm

/// Reminder options for scheduled `Bill`s
///
/// - `.never`: Do not remind the user
/// - `.onDate`: Remind on the day
/// - `.oneDay`: Remind one day before/after the due date
/// - `.twoDays`: Remind two days before/after the due date
/// - `.threeDays`: Remind three days before/after the due date
/// - `.oneWeek`: Remind one week before/after the due date
/// - `.twoWeeks`: Remind two weeks before/after the due date
enum BillDueReminder: String {
    case never, onDate, oneDay, twoDays, threeDays, oneWeek, twoWeeks
    static let allValues = [never, onDate, oneDay, twoDays, threeDays, oneWeek, twoWeeks]
    static let allRawValues = [never.rawValue, onDate.rawValue, oneDay.rawValue, twoDays.rawValue,
                               threeDays.rawValue, oneWeek.rawValue, twoWeeks.rawValue]
}

/// Repeat schedule options of the `Bill`
///
/// - `.never`: Do not repeat bill
/// - `.weekly`: Repeat the bill weekly
/// - `.monthly`: Repeat the biil monthly
/// - `.yearly`: Repeat the bill yearly
enum BillRepeatSchedule: String {
    case never, weekly, monthly, yearly
    static let allValues = [never, weekly, monthly, yearly]
    static let allRawValues = [never.rawValue, weekly.rawValue, monthly.rawValue, yearly.rawValue]
}

/// A Realm `Object` that represents a scheduled transaction
class Bill: Object {

    // MARK: - Properties
    /// The unique identifier of the `Bill`
    dynamic var id: String = ""
    
    /// The amount to be paid
    dynamic var amount: Double = 0.0
    
    /// The name of the `Bill`
    dynamic var name: String = ""
    
    /// Reminder option after the due date in raw value. See `BillDueReminder`
    dynamic var postDueReminder: String = ""
    
    /// Reminder option before the due date in raw value. See `BillDueReminder`
    dynamic var preDueReminder: String = ""
    
    /// The repeat option of the `Bill`. See `BillRepeatSchedule`
    dynamic var repeatSchedule: String = ""
    
    /// The date when the `Bill` starts
    dynamic var startDate: Date = Date()
    
    /// The `Category` of the `Bill`
    dynamic var category: Category?

    /// The entries under this `Bill`
    let entries = LinkingObjects(fromType: BillEntry.self, property: "bill")

    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - CRUD
    
    /// Saves the `Bill` to the realm given
    ///
    /// - Parameter realm: The realm to save the Bill to
    func save(toRealm realm: Realm) {
        do {
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the `Bill` to the given instance.
    /// Update will fail ig the `Bill`s do not have the same id.
    ///
    /// - Parameters:
    ///   - bill: The updated `Bill`
    ///   - realm: The realm to save the `Bill` to
    func update(to bill: Bill, in realm: Realm) {
        guard self.id == bill.id else { return }

        do {
            try realm.write {
                realm.add(bill, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Updates the `Bill` properties to the given values
    /// Update will fail ig the `Bill`s do not have the same id.
    ///
    /// - Parameters:
    ///   - amount: The new amount
    ///   - name: The new name
    ///   - postDueReminder: The new post reminder option
    ///   - preDueReminder: The new pre reminder option
    ///   - category: The new category
    ///   - realm: The realm to save the updated `Bill` to
    func update(amount: Double, name: String, postDueReminder: BillDueReminder,
                preDueReminder: BillDueReminder, category: Category, in realm: Realm) {
        guard (Bill.with(key: self.id, inRealm: realm) != nil) else { return }
        do {
            try realm.write {
                self.amount = amount
                self.name = name
                self.postDueReminder = postDueReminder.rawValue
                self.preDueReminder = preDueReminder.rawValue
                self.category = category
                realm.add(self, update: true)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Deletes the `Bill` from the given realm.
    /// Deletes other associated models.
    ///
    /// - Parameter realm: The realm to delete the `Bill` from
    func delete(in realm: Realm) {
        do {
            try realm.write {
                realm.delete(self.entries)
                realm.delete(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    /// Fetches the `Bill` with the given parameters
    ///
    /// - Parameters:
    ///   - key: The unique ID of the `Bill` to fetch
    ///   - realm: The realm to fetch the `Bill` from
    /// - Returns: The `Bill` fetched
    static func with(key: String, inRealm realm: Realm) -> Bill? {
        return realm.object(ofType: Bill.self, forPrimaryKey: key) as Bill?
    }

    /// Fetches all the `Bill`s with the given `Category`
    ///
    /// - Parameters:
    ///   - realm: The realm to fetch the `Bill`s from
    ///   - category: The `Category` of the `Bill`s to fetch
    /// - Returns: All the `Bill`s found in the given realm under the given `Category`
    static func all(in realm: Realm, underCategory category: Category) -> Results<Bill> {
        return realm.objects(Bill.self)
            .filter("category.id == %@", category.id)
            .sorted(byKeyPath: "name")
    }

    /// Fetches all the `Bill`s from the given realm
    ///
    /// - Parameter realm: The realm to fetch all the `Bill`s from
    /// - Returns: All the `Bill`s found in the given realm
    static func all(in realm: Realm) -> Results<Bill> {
        return realm.objects(Bill.self)
            .sorted(byKeyPath: "name")
    }

}
