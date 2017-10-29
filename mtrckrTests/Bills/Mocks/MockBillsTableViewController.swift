//
//  MockBillsTableViewController.swift
//  mtrckrTests
//
//  Created by User on 9/5/17.
//

import UIKit
@testable import mtrckr

class MockBillsTableViewController: NewBillViewControllerDelegate, PayBillViewControllerDelegate {
    
    var didSave = false
    var didEditBillEntry: BillEntry?
    var didEditBill: Bill?
    
    var amount: Double = 0
    var name = ""
    var post: String?
    var pre: String?
    var repeatSchedule: String?
    var startDate: Date?
    var category: mtrckr.Category?
    
    var didPay = false
    var didPayAmount: Double = 0
    var didPayAccount: Account?
    var didPayDate: Date?

    func saveNewBill(amount: Double, name: String, post: String, pre: String, repeat rSched: String,
                     startDate: Date, category: mtrckr.Category) {
        
        didSave = true
        self.amount = amount
        self.name = name
        self.post = post
        self.pre = pre
        self.repeatSchedule = rSched
        self.startDate = startDate
        self.category = category
    }
    
    func edit(billEntry: BillEntry, amount: Double, name: String, post: String, pre: String, repeatSchedule: String,
              startDate: Date, category: mtrckr.Category) {
        
        didEditBillEntry = billEntry
        self.amount = amount
        self.name = name
        self.post = post
        self.pre = pre
        self.repeatSchedule = repeatSchedule
        self.startDate = startDate
        self.category = category
    }
    
    func edit(bill: Bill, amount: Double, name: String, post: String, pre: String, repeatSchedule: String,
              startDate: Date, category: mtrckr.Category) {
        
        didEditBill = bill
        self.amount = amount
        self.name = name
        self.post = post
        self.pre = pre
        self.repeatSchedule = repeatSchedule
        self.startDate = startDate
        self.category = category
    }
    
    func proceedPayment(ofBill entry: BillEntry, amount: Double, account: Account, date: Date) {
        didPay = true
        didPayAmount = amount
        didPayAccount = account
        didPayDate = date
    }
}
