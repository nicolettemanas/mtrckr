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

enum BillDueReminder: String {
    case never, onDate, oneDay, twoDays, threeDays, oneWeek, twoWeeks
}

enum BillRepeatSchedule: String {
    case never, weekly, monthly, yearly
}

class Bill: Object {

    dynamic var id: String = ""
    dynamic var amount: Double = 0.0
    dynamic var name: String = ""
    dynamic var postDueReminder: String = ""
    dynamic var preDueReminder: String = ""
    dynamic var repeatSchedule: String = ""
    dynamic var startDate: Date = Date()
//    dynamic var user: User?
    dynamic var category: Category?

    let entries = LinkingObjects(fromType: BillEntry.self, property: "bill")

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

    static func with(key: String, inRealm realm: Realm) -> Bill? {
        return realm.object(ofType: Bill.self, forPrimaryKey: key) as Bill?
    }

    static func all(in realm: Realm, underCategory category: Category) -> Results<Bill> {
        return realm.objects(Bill.self)
            .filter("category.id == %@", category.id)
            .sorted(byKeyPath: "name")
    }

    static func all(in realm: Realm) -> Results<Bill> {
        return realm.objects(Bill.self)
            .sorted(byKeyPath: "name")
    }

}
