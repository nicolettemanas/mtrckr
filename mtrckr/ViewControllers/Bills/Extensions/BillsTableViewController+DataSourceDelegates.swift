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
        presenter?.showHistory(of: entry)
    }
    
    func didPressPayBill(entry: BillEntry) {
        billVCPresenter?.presentPayment(ofBill: entry, presenter: self)
//        presenter?.payEntry(entry: entry)
    }
}
