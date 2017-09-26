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
    
    var newEntry: BillEntry?
    var createdBill: Bill?
    var updatedBill: Bill?
    
    override func saveBill(bill: Bill) {
        createdBill = bill
    }
    
    override func deleteBill(bill: BillEntry, type: ModifyBillType) {
        didDeleteBill = bill
        deleteType = type
    }
    
    override func updateBillEntry(entry: BillEntry, toEntry: BillEntry) {
        newEntry = entry
    }
    
    override func update(oldBill: Bill, toBill newBill: Bill) {
        updatedBill = newBill
    }
}
