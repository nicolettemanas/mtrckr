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
    func unpay(entry: BillEntry)
    func payEntry(entry: BillEntry, amount: Double, account: Account, date: Date)
    func deleteBillEntry(entry: BillEntry, deleteType: ModifyBillType)
    func createBill(amount: Double, name: String, post: String, pre: String,
                    repeat: String, startDate: Date, category: Category)
    func editBillEntry(billEntry: BillEntry, amount: Double, name: String, post: String,
                       pre: String, startDate: Date, category: Category)
    func editBillAndEntries(bill: Bill, amount: Double, name: String, post: String, pre: String,
                            repeat: String, startDate: Date, category: Category)

    var interactor: BillsInteractorProtocol? { get set }
}

/// Event handler for `BillsTableViewController`
class BillsPresenter: BillsPresenterProtocol {

    /// The interactor responsible for `Bill` and `BillEntry` modifications
    var interactor: BillsInteractorProtocol?

    /// Initializer. Creates an `BillsPresenter` with the given interactor that conforms to `BillsInteractorProtocol`
    ///
    /// - Parameter interactor: The interactor to use in `Bill` or `BillEntry` modifications
    init(interactor: BillsInteractorProtocol) {
        self.interactor = interactor
    }

    /// Creates an untracked `Bill` and passes it to the interactor to save
    ///
    /// - Parameters:
    ///   - amount: The amount of the `Bill`
    ///   - name: The name of the `Bill`
    ///   - post: The post-reminder of the `Bill`
    ///   - pre: The pre-reminder of the `Bill`
    ///   - repeatSchedule: The repeat schedule of the `Bill`
    ///   - startDate: The start date of the `Bill`
    ///   - category: The `Category` of the `Bill`
    func createBill(amount: Double, name: String, post: String, pre: String,
                    repeat repeatSchedule: String, startDate: Date, category: Category) {

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

    /// Invoked when confirmed to delete a `BillEntry` and asks the interactor
    /// to delete entries depending on the type of deletion given
    ///
    /// - Parameters:
    ///   - entry: The `BillEntry` to delete
    ///   - deleteType: The tyepe of deletion given
    func deleteBillEntry(entry: BillEntry, deleteType: ModifyBillType) {
        switch deleteType {
        case .allBills:
            assert(entry.bill?.active == true)
            interactor?.delete(bill: entry.bill!)
        case .currentBill: interactor?.delete(billEntry: entry)
        }
    }

    /// Asks the interactor to pay the `BillEntry`
    ///
    /// - Parameters:
    ///   - entry: The `BillEntry` to be paid
    ///   - amount: The amount to pay
    ///   - account: The `Account` to record the payment as a `Transaction`
    ///   - date: The date of the `Transaction` to be generated
    func payEntry(entry: BillEntry, amount: Double, account: Account, date: Date) {
        interactor?
            .payEntry(entry     : entry,
                      amount    : amount,
                      account   : account,
                      date      : date)
    }

    /// Asks interactor to edit a single `BillEntry` with the given values
    ///
    /// - Parameters:
    ///   - billEntry: The `BillEntry` to be edited
    ///   - amount: The new amount of the `BillEntry`
    ///   - name: The new name of the `BillEntry`
    ///   - post: The new post-reminder of the `BillEntry`
    ///   - pre: The new pre-reminder of the `BillEntry`
    ///   - startDate: The new start date of the `BillEntry`
    ///   - category: The new `Category` of the `BillEntry`
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

    /// Asks the interactor to edit all the unpaid entries of the given `Bill`
    ///
    /// - Parameters:
    ///   - bill: The `Bill` to be edited
    ///   - amount: The new amount of the `Bill`
    ///   - name: The new name of the `Bill`
    ///   - post: The new post-reminder of the `Bill`
    ///   - pre: The new pre-reminder of the `Bill`
    ///   - repeatSchedule: The new repeat schedule of the `Bill`
    ///   - startDate: The new start date of the `Bill`
    ///   - category: The new `Category` of the `Bill`
    func editBillAndEntries(bill: Bill, amount: Double, name: String, post: String, pre: String,
                            repeat repeatSchedule: String, startDate: Date, category: Category) {

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

    /// Asks the interactor to skip a `BillEntry`
    ///
    /// - Parameter entry: The `BillEntry` to be marked as skipped
    func skip(entry: BillEntry) {
        interactor?.skip(entry: entry, date: Date())
    }

    /// Asks the interactor to unpay a `BillEntry`
    ///
    /// - Parameter entry: The `BillEntry` to be marked as unpaid
    func unpay(entry: BillEntry) {
        interactor?.unpay(entry: entry)
    }
}
