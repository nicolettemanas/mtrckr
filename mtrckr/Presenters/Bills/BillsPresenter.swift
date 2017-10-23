//
//  BillsPresenter.swift
//  mtrckr
//
//  Created by User on 8/23/17.
//

import UIKit
import RealmSwift

protocol BillsPresenterProtocol {
    func skip(entry: BillEntry)
    func showHistory(of entry: BillEntry)
    func payEntry(entry: BillEntry, amount: Double, account: Account, date: Date)
    func deleteBillEntry(entry: BillEntry, deleteType: ModifyBillType)
    func createBill(amount: Double, name: String, post: String, pre: String,
                    repeatSchedule: String, startDate: Date, category: Category)
    func editBillEntry(billEntry: BillEntry, amount: Double, name: String, post: String,
                       pre: String, startDate: Date, category: Category)
    func editBillAndEntries(bill: Bill, amount: Double, name: String, post: String, pre: String,
                            repeatSchedule: String, startDate: Date, category: Category)
    
    var interactor: BillsInteractorProtocol? { get set }
}

class BillsPresenter: BillsPresenterProtocol {
    
    var interactor: BillsInteractorProtocol?
    
    init(interactor: BillsInteractorProtocol) {
        self.interactor = interactor
    }
    
    func createBill(amount: Double, name: String, post: String, pre: String,
                    repeatSchedule: String, startDate: Date, category: Category) {
        
        let bill = Bill(value:
            ["id": "BILL-\(NSUUID().uuidString)",
            "amount": amount,
            "name": name,
            "postDueReminder": post,
            "preDueReminder": pre,
            "repeatSchedule": repeatSchedule,
            "startDate": startDate,
            "category": category
            ])
        
        interactor?.saveBill(bill: bill)
    }
    
    func deleteBillEntry(entry: BillEntry, deleteType: ModifyBillType) {
        switch deleteType {
            case .allBills:
                assert(entry.bill?.active == true)
                interactor?.delete(bill: entry.bill!)
            case .currentBill: interactor?.delete(billEntry: entry)
        }
    }
    
    func showHistory(of entry: BillEntry) {
        
    }
    
    func payEntry(entry: BillEntry, amount: Double, account: Account, date: Date) {
        interactor?
            .payEntry(entry     : entry,
                      amount    : amount,
                      account   : account,
                      date      : date)
    }
    
    func editBillEntry(billEntry: BillEntry, amount: Double, name: String, post: String,
                       pre: String, startDate: Date, category: Category) {
        
        guard let preReminder = BillDueReminder(rawValue: pre) else { return }
        guard let postReminder = BillDueReminder(rawValue: post) else { return }
        interactor?
            .update(entry      : billEntry,
                    amount     : amount,
                    name       : name,
                    preDue     : preReminder,
                    postDue    : postReminder,
                    category   : category,
                    dueDate    : startDate)
    }
    
    func editBillAndEntries(bill: Bill, amount: Double, name: String, post: String, pre: String,
                            repeatSchedule: String, startDate: Date, category: Category) {
        
        guard let preReminder = BillDueReminder(rawValue: pre) else { return }
        guard let postReminder = BillDueReminder(rawValue: post) else { return }
        guard let repeatSched = BillRepeatSchedule(rawValue: repeatSchedule) else { return }
        interactor?
            .update(bill        : bill,
                    amount      : amount,
                    name        : name,
                    post        : postReminder,
                    preDue      : preReminder,
                    category    : category,
                    startDate   : startDate,
                    repeatSched : repeatSched)
    }
    
    func skip(entry: BillEntry) {
        interactor?.skip(entry: entry, date: Date())
    }
}
