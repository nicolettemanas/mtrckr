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
    
    var updatedAmount: Double?
    var updatedName: String?
    var updatedPre: String?
    var updatedPost: String?
    var updatedCat: mtrckr.Category?
    var updatedDate: Date?
    
    override func saveBill(bill: Bill) {
        createdBill = bill
    }
    
    override func deleteBill(bill: BillEntry, type: ModifyBillType) {
        didDeleteBill = bill
        deleteType = type
    }
    
    override func updateBillEntry(entry: BillEntry, amount: Double, name: String?, preDueReminder: String?,
                                  postDueReminder: String?, category: mtrckr.Category?, dueDate: Date) {
        updatedAmount = amount
        updatedName = name
        updatedPre = preDueReminder
        updatedPost = postDueReminder
        updatedCat = category
        updatedDate = dueDate
    }
    
    override func update(oldBill: Bill, toBill newBill: Bill) {
        updatedBill = newBill
    }
}
