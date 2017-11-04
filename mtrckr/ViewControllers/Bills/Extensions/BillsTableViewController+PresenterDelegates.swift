//
//  BillsTableViewController+DeleteBillPresenterDelegate.swift
//  mtrckr
//
//  Created by User on 10/13/17.
//

import Foundation

extension BillsTableViewController: DeleteBillPresenterDelegate {
    func proceedDeleteEntry(entry: BillEntry, type: ModifyBillType) {
        presenter?.deleteBillEntry(entry: entry, deleteType: type)
    }
    
    func cancelDeleteEntry(entry: BillEntry) {
        
    }
}
