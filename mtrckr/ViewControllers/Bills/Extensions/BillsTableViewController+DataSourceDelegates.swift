//
//  BillsTableViewController+BillsDataSourceDelegate.swift
//  mtrckr
//
//  Created by User on 10/13/17.
//

import Foundation
import RealmSwift

extension BillsTableViewController: BillsDataSourceDelegate {
    func didUpdateBills(withChanges changes: RealmCollectionChange<Results<Bill>>) {
        print("UPDATED: Bills")
    }
    
    func didSelect(entry: BillEntry) {
        assert(entry.bill?.active == true)
        guard let bill = entry.bill else { fatalError("Bill must not be nil") }
        billVCPresenter?.presentHistory(ofBill: bill, presenter: self)
    }
    
    func didPressPayBill(entry: BillEntry) {
        billVCPresenter?.presentPayment(ofBill: entry, presenter: self)
    }
}
