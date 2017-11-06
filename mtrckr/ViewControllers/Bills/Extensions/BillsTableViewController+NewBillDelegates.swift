//
//  BillsTableViewController+NewBillViewControllerDelegate.swift
//  mtrckr
//
//  Created by User on 10/13/17.
//

import Foundation
import SwipeCellKit

/// :nodoc:
protocol NewBillViewControllerDelegate: class {
    func saveNewBill(amount: Double, name: String, post: String, pre: String,
                     repeat: String, startDate: Date, category: Category)
    func edit(billEntry: BillEntry, amount: Double, name: String, post: String, pre: String,
              repeatSchedule: String, startDate: Date, category: Category)
    func edit(bill: Bill, amount: Double, name: String, post: String, pre: String,
              repeatSchedule: String, startDate: Date, category: Category)
}

/// :nodoc:
protocol PayBillViewControllerDelegate: class {
    func proceedPayment(ofBill entry: BillEntry, amount: Double, account: Account, date: Date)
}

extension BillsTableViewController: NewBillViewControllerDelegate {
    func saveNewBill(amount: Double, name: String, post: String, pre: String,
                     repeat rep: String, startDate: Date, category: Category) {
        presenter?
            .createBill(amount      : amount,
                        name        : name,
                        post        : post,
                        pre         : pre,
                        repeat      : rep,
                        startDate   : startDate,
                        category    : category)
    }
    
    func edit(billEntry: BillEntry, amount: Double, name: String, post: String,
              pre: String, repeatSchedule: String, startDate: Date, category: Category) {
        if let cell = tableView.cellForRow(at: editingIndexPath!) as? SwipeTableViewCell {
            cell.hideSwipe(animated: true)
            editingIndexPath = nil
        }
        
        presenter?
            .editBillEntry(billEntry    : billEntry,
                           amount       : amount,
                           name         : name,
                           post         : post,
                           pre          : pre,
                           startDate    : startDate,
                           category     : category)
    }
    
    func edit(bill: Bill, amount: Double, name: String, post: String, pre: String,
              repeatSchedule: String, startDate: Date, category: Category) {
        
        if let cell = tableView.cellForRow(at: editingIndexPath!) as? SwipeTableViewCell {
            cell.hideSwipe(animated: true)
            editingIndexPath = nil
        }
        
        presenter?
            .editBillAndEntries(bill        : bill,
                                amount      : amount,
                                name        : name,
                                post        : post,
                                pre         : pre,
                                repeat      : repeatSchedule,
                                startDate   : startDate,
                                category    : category)
    }
}

extension BillsTableViewController: PayBillViewControllerDelegate {
    func proceedPayment(ofBill entry: BillEntry, amount: Double, account: Account, date: Date) {
        presenter?
            .payEntry(entry     : entry,
                      amount    : amount,
                      account   : account,
                      date      : date)
    }
}
