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
    func saveBill(bill: Bill)
    func deleteBill(bill: BillEntry, type: ModifyBillType)
    func updateBillEntry(entry: BillEntry, amount: Double, name: String?, preDueReminder: BillDueReminder,
                         postDueReminder: BillDueReminder, category: Category?, dueDate: Date)
    func update(bill: Bill, amount: Double, name: String, postDueReminder: BillDueReminder,
                preDueReminder: BillDueReminder, category: Category, startDate: Date, repeatSchedule: BillRepeatSchedule)
}

class BillsInteractor: RealmHolder, BillsInteractorProtocol {
    func deleteBill(bill: BillEntry, type: ModifyBillType) {
        
    }
    
    func saveBill(bill: Bill) {
        guard let sched = BillRepeatSchedule(rawValue: bill.repeatSchedule) else {
            fatalError("Invalid repeat schedule '\(bill.repeatSchedule)'")
        }
        createEntries(forBill: bill, startDate: bill.startDate, repeatSched: sched)
        bill.save(toRealm: self.realmContainer!.userRealm!)
    }
    
    func updateBillEntry(entry: BillEntry, amount: Double, name: String?, preDueReminder: BillDueReminder,
                         postDueReminder: BillDueReminder, category: Category?, dueDate: Date) {
        entry.update(amount: amount, name: name, preDueReminder: preDueReminder, postDueReminder: postDueReminder,
                     category: category, dueDate: dueDate, inRealm: self.realmContainer!.userRealm!)
    }
    
    func update(bill: Bill, amount: Double, name: String, postDueReminder: BillDueReminder,
                preDueReminder: BillDueReminder, category: Category, startDate: Date, repeatSchedule: BillRepeatSchedule) {
        updateUnpaidEntries(ofBill: bill, amount: amount, name: name,
                            post: postDueReminder, pre: preDueReminder,
                            category: category, startDate: startDate == bill.startDate ? nil: startDate,
                            repeatSchedule: repeatSchedule)
        bill.update(amount: amount, name: name, postDueReminder: postDueReminder,
                    preDueReminder: preDueReminder, category: category, in: realmContainer!.userRealm!)
    }
    
    // MARK: - Private methods
    private func updateUnpaidEntries(ofBill bill: Bill, amount: Double, name: String,
                                     post: BillDueReminder, pre: BillDueReminder, category: Category,
                                     startDate: Date?, repeatSchedule: BillRepeatSchedule) {
        
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
            entry.update(amount: amount, name: name, preDueReminder: pre, postDueReminder: post,
                         category: category, dueDate: entry.dueDate, inRealm: realmContainer!.userRealm!)
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
