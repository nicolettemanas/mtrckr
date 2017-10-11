//
//  MockBillsInteractor.swift
//  mtrckrTests
//
//  Created by User on 8/25/17.
//

import UIKit
@testable import mtrckr

class MockBillsInteractor: BillsInteractor {
    
    var didDeleteBill: BillEntry?
    var deleteType: ModifyBillType?
    
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
    
    override func saveBill(bill: Bill) {
        createdBill = bill
    }
    
    override func deleteBill(bill: BillEntry, type: ModifyBillType) {
        didDeleteBill = bill
        deleteType = type
    }
    
    override func updateBillEntry(entry: BillEntry, amount: Double, name: String?, preDueReminder: BillDueReminder,
                                  postDueReminder: BillDueReminder, category: mtrckr.Category?, dueDate: Date) {
        updatedAmount = amount
        updatedName = name
        updatedPre = preDueReminder
        updatedPost = postDueReminder
        updatedCat = category
        updatedDate = dueDate
    }
    
    override func update(bill: Bill, amount: Double, name: String, postDueReminder: BillDueReminder,
                         preDueReminder: BillDueReminder, category: mtrckr.Category, startDate: Date, repeatSchedule: BillRepeatSchedule) {
        billToUpdate = bill
        updatedAmount = amount
        updatedName = name
        updatedPre = preDueReminder
        updatedPost = postDueReminder
        updatedCat = category
        updatedDate = startDate
        updatedRepeat = repeatSchedule
    }
}
