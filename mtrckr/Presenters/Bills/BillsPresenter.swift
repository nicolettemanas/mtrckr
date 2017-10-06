//
//  BillsPresenter.swift
//  mtrckr
//
//  Created by User on 8/23/17.
//

import UIKit
import RealmSwift

protocol BillsPresenterProtocol {
    func createBill(amount: Double, name: String, post: String, pre: String,
                    repeatSchedule: String, startDate: Date, category: Category)
    func deleteBillEntry(entry: BillEntry, deleteType: ModifyBillType)
    func editBillEntry(billEntry: BillEntry, amount: Double, name: String, post: String,
                       pre: String, startDate: Date, category: Category)
    func editBillAndEntries(bill: Bill, amount: Double, name: String, post: String, pre: String,
                            repeatSchedule: String, startDate: Date, category: Category, proceedingDate: Date)
    func showHistory(of entry: BillEntry)
    func payEntry(entry: BillEntry)
    
    var interactor: BillsInteractorProtocol? { get set }
}

class BillsPresenter: BillsPresenterProtocol {
    
    var interactor: BillsInteractorProtocol?
    
    init(interactor: BillsInteractorProtocol) {
        self.interactor = interactor
    }
    
    func createBill(amount: Double, name: String, post: String, pre: String,
                    repeatSchedule: String, startDate: Date, category: Category) {
        
        let bill = Bill(value: ["id": "BILL-\(NSUUID().uuidString)",
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
        interactor?.deleteBill(bill: entry, type: deleteType)
    }
    
    func showHistory(of entry: BillEntry) {
        
    }
    
    func payEntry(entry: BillEntry) {
        
    }
    
    func editBillEntry(billEntry: BillEntry, amount: Double, name: String, post: String,
                       pre: String, startDate: Date, category: Category) {
        interactor?.updateBillEntry(entry: billEntry, amount: amount, name: name, preDueReminder: pre,
                                    postDueReminder: post, category: category, dueDate: startDate)
    }
    
    func editBillAndEntries(bill: Bill, amount: Double, name: String, post: String, pre: String,
                            repeatSchedule: String, startDate: Date, category: Category, proceedingDate: Date) {
        
        let newBill = bill
        newBill.amount = amount
        newBill.name = name
        newBill.postDueReminder = post
        newBill.preDueReminder = pre
        newBill.repeatSchedule = repeatSchedule
        newBill.startDate = startDate
        newBill.category = category
        
        interactor?.update(oldBill: bill, toBill: newBill)
    }
}
