//
//  BillsInteractor.swift
//  mtrckr
//
//  Created by User on 8/17/17.
//

import UIKit
import RealmSwift
import DateToolsSwift

protocol BillsInteractorProtocol {
    func delete(bill: Bill)
    func saveBill(bill: Bill)
    func delete(billEntry: BillEntry)
    func skip(entry: BillEntry, date: Date)
    func unpay(entry: BillEntry)
    func payEntry(entry: BillEntry, amount: Double, account: Account, date: Date)
    func update(entry: BillEntry, amount: Double, name: String?, preDue: BillDueReminder,
                postDue: BillDueReminder, category: Category?, dueDate: Date)
    func update(bill: Bill, amount: Double, name: String, post: BillDueReminder,
                preDue: BillDueReminder, category: Category, startDate: Date,
                repeatSched: BillRepeatSchedule)
}

/// Class responsible for `Bill` and `BillEntry` modification methods
class BillsInteractor: RealmHolder, BillsInteractorProtocol {
    
    /// Deletes a `Bill` and corresponding unpaid `BillEntries`
    ///
    /// - Parameter bill: The `Bill` to be deleted
    func delete(bill: Bill) {
        deleteAllUnpaid(for: bill)
        bill.deactivate(inRealm: realmContainer!.userRealm!)
    }
    
    /// Deletes a single `BillEntry`
    ///
    /// - Parameter billEntry: The `BillEntry` to be deleted
    func delete(billEntry: BillEntry) {
        billEntry.delete(in: realmContainer!.userRealm!)
    }
    
    /// Saves a bill and generates corresponding bill entries
    ///
    /// - Parameter bill: The `Bill` to save
    func saveBill(bill: Bill) {
        guard let sched = BillRepeatSchedule(rawValue: bill.repeatSchedule) else {
            fatalError("Invalid repeat schedule '\(bill.repeatSchedule)'")
        }
        
        createEntries(forBill       : bill,
                      startDate     : bill.startDate,
                      repeatSched   : sched)
        
        bill.save(toRealm: self.realmContainer!.userRealm!)
    }
    
    /// Marks the `BillEntry` as skipped
    ///
    /// - Parameters:
    ///   - entry: The `BillEntry` to be modified
    ///   - date: Date modified
    func skip(entry: BillEntry, date: Date) {
        entry.skip(inRealm: self.realmContainer!.userRealm!)
    }
    
    func unpay(entry: BillEntry) {
        entry.unpay(inRealm: realmContainer!.userRealm!)
    }
    
    /// Marks an entry as paid and generates associated `Transaction`
    ///
    /// - Parameters:
    ///   - entry: The `BillEntry` to be marked as paid
    ///   - amount: The amount paid
    ///   - account: The `Account` where the `Transaction` will be recorded
    ///   - date: The date of the `Transaction`
    func payEntry(entry: BillEntry, amount: Double, account: Account, date: Date) {
        entry
            .pay(amount        : amount,
                 description   : "",
                 fromAccount   : account,
                 datePaid      : date,
                 inRealm       : realmContainer!.userRealm!)
    }
    
    func update(entry: BillEntry, amount: Double, name: String?,
                preDue: BillDueReminder, postDue: BillDueReminder,
                category: Category?, dueDate: Date) {
        
        entry.update(amount             : amount,
                     name               : name,
                     preDueReminder     : preDue,
                     postDueReminder    : postDue,
                     category           : category,
                     dueDate            : dueDate,
                     inRealm            : self.realmContainer!.userRealm!)
    }
    
    func update(bill: Bill, amount: Double, name: String, post: BillDueReminder,
                preDue: BillDueReminder, category: Category, startDate: Date, repeatSched: BillRepeatSchedule) {
        
        updateUnpaidEntries(ofBill          : bill,
                            amount          : amount,
                            name            : name,
                            post            : post,
                            pre             : preDue,
                            category        : category,
                            startDate       : startDate == bill.startDate ? nil: startDate,
                            repeatSchedule  : repeatSched)
        
        bill.update(amount          : amount,
                    name            : name,
                    postDueReminder : post,
                    preDueReminder  : preDue,
                    category        : category,
                    in              : realmContainer!.userRealm!)
    }
    
    // MARK: - Private methods
    private func updateUnpaidEntries(ofBill bill: Bill, amount: Double, name: String,
                                     post: BillDueReminder, pre: BillDueReminder, category: Category,
                                     startDate: Date?, repeatSchedule: BillRepeatSchedule) {
        assert(bill.active == true)
        deleteAllUnpaid(for: bill)
        
        let latestPaid = latestPaidEntry(for: bill)
        var start: Date!
        if startDate == nil {
            if let lPaid = latestPaid {
                start = lPaid.dueDate.add(timeChunk(of: lPaid.bill!.repeatSchedule))
            } else { start = bill.startDate }
        } else { start = startDate }
        
        createEntries(forBill: bill, startDate: start, repeatSched: repeatSchedule)
        let unpaidEntries = BillEntry.allUnpaid(in: realmContainer!.userRealm!, for: [bill])
        for entry in unpaidEntries {
            entry.update(amount             : amount,
                         name               : name,
                         preDueReminder     : pre,
                         postDueReminder    : post,
                         category           : category,
                         dueDate            : entry.dueDate,
                         inRealm            : realmContainer!.userRealm!)
        }
    }
    
    private func deleteAllUnpaid(for bill: Bill) {
        let unpaidEntries = BillEntry.allUnpaid(in: realmContainer!.userRealm!, for: [bill])
        for entry in unpaidEntries {
            entry.delete(in: realmContainer!.userRealm!)
        }
    }
    
    private func latestPaidEntry(for bill: Bill) -> BillEntry? {
        return BillEntry.all(in: realmContainer!.userRealm!, for: bill)
            .sorted(byKeyPath: "dueDate")
            .filter(NSPredicate(format: "status == %@ OR status == %@",
                                BillEntryStatus.paid.rawValue,
                                BillEntryStatus.skipped.rawValue)).first
    }
    
    private func createEntries(forBill bill: Bill, startDate: Date, repeatSched: BillRepeatSchedule) {
        assert(bill.active == true)
        var start = startDate
        var end = Date()
        
        if end.isEarlier(than: start) {
            end = bill.startDate
            start = Date().isEarlier(than: end) ? bill.startDate : Date()
        }
        
        let repeatTimeChunk = timeChunk(of: repeatSched.rawValue)
        while start.isEarlierThanOrEqual(to: end) {
            BillEntry(dueDate: start, for: bill)
                .save(toRealm: self.realmContainer!.userRealm!)
            start = start.add(repeatTimeChunk)
            if bill.repeatSchedule == BillRepeatSchedule.never.rawValue { break }
        }
    }
    
    private func timeChunk(of repeatSchedule: String) -> TimeChunk {
        var repeatChunk = 0.days
        switch repeatSchedule {
            case BillRepeatSchedule.yearly.rawValue: repeatChunk = 1.years
            case BillRepeatSchedule.monthly.rawValue: repeatChunk = 1.months
            case BillRepeatSchedule.weekly.rawValue: repeatChunk = 1.weeks
            default: break
        }
        return repeatChunk
    }
}
