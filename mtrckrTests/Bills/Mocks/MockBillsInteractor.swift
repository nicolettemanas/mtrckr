//
//  MockBillsInteractor.swift
//  mtrckrTests
//
//  Created by User on 8/25/17.
//

import UIKit
@testable import mtrckr

class MockBillsInteractor: BillsInteractor {
    
    var didDeleteBillEntry: BillEntry?
    var didDeleteBill: Bill?
    
    var createdBill: Bill?
    var updatedBill: Bill?
    var billToUpdate: Bill?
    
    var updatedAmount: Double?
    var updatedName: String?
    var updatedPre: BillDueReminder?
    var updatedPost: BillDueReminder?
    var updatedCat: mtrckr.Category?
    var updatedDate: Date?
    var updatedRepeat: BillRepeatSchedule?
    
    var entryToPay: BillEntry?
    var payAccount: Account?
    var payAmount: Double = 0
    var payDate: Date?
    
    var entryToSkip: BillEntry?
    var entryToUnpay: BillEntry?
    
    override func saveBill(bill: Bill) {
        createdBill = bill
    }
    
    override func delete(bill: Bill) {
        didDeleteBill = bill
    }
    
    override func delete(billEntry: BillEntry) {
        didDeleteBillEntry = billEntry
    }
    
    override func update(entry: BillEntry, amount: Double, name: String?, preDue preDueReminder: BillDueReminder,
                         postDue postDueReminder: BillDueReminder, category: mtrckr.Category?, dueDate: Date) {
        updatedAmount = amount
        updatedName = name
        updatedPre = preDueReminder
        updatedPost = postDueReminder
        updatedCat = category
        updatedDate = dueDate
    }
    
    override func update(bill: Bill, amount: Double, name: String, post: BillDueReminder,
                         preDue: BillDueReminder, category: mtrckr.Category, startDate: Date, repeatSched: BillRepeatSchedule) {
        billToUpdate = bill
        updatedAmount = amount
        updatedName = name
        updatedPre = preDue
        updatedPost = post
        updatedCat = category
        updatedDate = startDate
        updatedRepeat = repeatSched
    }
    
    override func payEntry(entry: BillEntry, amount: Double, account: Account, date: Date) {
        entryToPay = entry
        payAmount = amount
        payAccount = account
        payDate = date
    }
    
    override func skip(entry: BillEntry, date: Date) {
        entryToSkip = entry
    }
    
    override func unpay(entry: BillEntry) {
        entryToUnpay = entry
    }
}
