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
    func updateBillEntry(entry: BillEntry, amount: Double, name: String?, preDueReminder: String?,
                         postDueReminder: String?, category: Category?, dueDate: Date)
    func update(oldBill: Bill, toBill newBill: Bill)
}

class BillsInteractor: RealmHolder, BillsInteractorProtocol {
    func deleteBill(bill: BillEntry, type: ModifyBillType) {
        
    }
    
    func saveBill(bill: Bill) {
        createEntries(forBill: bill, startDate: bill.startDate, repeatSched: bill.repeatSchedule)
        bill.save(toRealm: self.realmContainer!.userRealm!)
    }
    
    func updateBillEntry(entry: BillEntry, amount: Double, name: String?, preDueReminder: String?,
                         postDueReminder: String?, category: Category?, dueDate: Date) {
        entry.update(amount: amount, name: name, preDueReminder: preDueReminder, postDueReminder: postDueReminder,
                     category: category, dueDate: dueDate, inRealm: self.realmContainer!.userRealm!)
    }
    
    func update(oldBill: Bill, toBill newBill: Bill) {
        updateUnpaidEntries(ofBill: oldBill, amount: newBill.amount, name: newBill.name,
                            post: newBill.postDueReminder, pre: newBill.preDueReminder,
                            category: newBill.category!,
                            startDate: oldBill.startDate == newBill.startDate ? nil: newBill.startDate,
                            repeatSchedule: newBill.repeatSchedule)
        oldBill.update(to: newBill, in: realmContainer!.userRealm!)
    }
    
    // MARK: - Private methods
    private func updateUnpaidEntries(ofBill bill: Bill, amount: Double, name: String,
                                     post: String, pre: String, category: Category,
                                     startDate: Date?, repeatSchedule: String) {
        var unpaidEntries = BillEntry.allUnpaid(in: realmContainer!.userRealm!, for: [bill])
        for entry in unpaidEntries {
            entry.delete(in: realmContainer!.userRealm!)
        }
        
        let latestPaid = BillEntry.all(in: realmContainer!.userRealm!, for: bill)
            .sorted(byKeyPath: "dueDate")
            .filter(NSPredicate(format: "status == %@ OR status == %@",
                                BillEntryStatus.paid.rawValue, BillEntryStatus.skipped.rawValue))
        
        var start = startDate
        if start == nil {
            start = latestPaid.first?.dueDate
                .add(timeChunk(of: latestPaid.first!.bill!.repeatSchedule)) ?? bill.startDate
        }
        
        createEntries(forBill: bill, startDate: start!, repeatSched: repeatSchedule)
        unpaidEntries = BillEntry.allUnpaid(in: realmContainer!.userRealm!, for: [bill])
        for entry in unpaidEntries {
            entry.update(amount: amount, name: name, preDueReminder: pre, postDueReminder: post,
                         category: category, dueDate: entry.dueDate, inRealm: realmContainer!.userRealm!)
        }
    }
    
    private func createEntries(forBill bill: Bill, startDate: Date, repeatSched: String) {
        var start = startDate
        var end = Date()
        
        if end.isEarlier(than: start) {
            end = bill.startDate
            start = Date().isEarlier(than: end) ? bill.startDate : Date()
        }
        
        let repeatTimeChunk = timeChunk(of: repeatSched)
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
