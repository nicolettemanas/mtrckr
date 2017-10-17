//
//  MockBillsPresenter.swift
//  mtrckrTests
//
//  Created by User on 8/23/17.
//

import UIKit
@testable import mtrckr

class MockBillsPresenter: BillsPresenter {
    var didCreate = false
    var didCreateAmount = 0.0
    var didCreateName: String?
    var didCreatePost: String?
    var didCreatePre: String?
    var didCreateRepeat: String?
    var didCreateStartDate: Date?
    var didCreateCategory: mtrckr.Category?
    
    var didDelete = false
    var didDeleteEntry: BillEntry?
    var deleteType: ModifyBillType?
    
    var didShowHistory = false
    var didShowHistoryOf: BillEntry?
    
    var didPayBill = false
    var didPayBillEntry: BillEntry?
    var didPayAccount: Account?
    var didPayAmount: Double = 0
    var didPayDate: Date?
    
    var didEdit = false
    var didEditEntry: BillEntry?
    var didEditBill: Bill?
    
    var didEditEntryAmount = 0.0
    var didEditEntryName: String?
    var didEditEntryPost: String?
    var didEditEntryPre: String?
    var didEditEntryStartDate: Date?
    var didEditEntryCategory: mtrckr.Category?
    
    var didEditBillAmount = 0.0
    var didEditBillName: String?
    var didEditBillPost: String?
    var didEditBillPre: String?
    var didEditBillRepeatSchedule: String?
    var didEditBillStartDate: Date?
    var didEditBillCategory: mtrckr.Category?
    
    override func createBill(amount: Double, name: String, post: String, pre: String,
                             repeatSchedule: String, startDate: Date, category: mtrckr.Category) {
        didCreate = true
        didCreateAmount = amount
        didCreateName = name
        didCreatePost = post
        didCreatePre = pre
        didCreateRepeat = repeatSchedule
        didCreateStartDate = startDate
        didCreateCategory = category
    }
    
    override func deleteBillEntry(entry: BillEntry, deleteType type: ModifyBillType) {
        didDelete = true
        didDeleteEntry = entry
        deleteType = type
    }
    
    override func editBillEntry(billEntry: BillEntry, amount: Double, name: String, post: String,
                                pre: String, startDate: Date, category: mtrckr.Category) {
        didEdit = true
        didEditEntry = billEntry
        
        didEditEntryAmount = amount
        didEditEntryName = name
        didEditEntryPost = post
        didEditEntryPre = pre
        didEditEntryStartDate = startDate
        didEditEntryCategory = category
    }
    
    override func editBillAndEntries(bill: Bill, amount: Double, name: String, post: String, pre: String,
                                     repeatSchedule: String, startDate: Date, category: mtrckr.Category) {
        didEdit = true
        didEditBill = bill
        
        didEditBillAmount = amount
        didEditBillName = name
        didEditBillPost = post
        didEditBillPre = pre
        didEditBillStartDate = startDate
        didEditBillCategory = category
        didEditBillRepeatSchedule = repeatSchedule
    }
    
    override func showHistory(of entry: BillEntry) {
        didShowHistory = true
        didShowHistoryOf = entry
    }
    
    override func payEntry(entry: BillEntry, amount: Double, account: Account, date: Date) {
        didPayBill = true
        didPayBillEntry = entry
        didPayDate = date
        didPayAmount = amount
        didPayAccount = account
    }
}
