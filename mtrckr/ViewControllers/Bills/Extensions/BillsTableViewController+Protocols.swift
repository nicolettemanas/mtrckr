//
//  BillsTableViewController+BillsTableViewControllerProtocol.swift
//  mtrckr
//
//  Created by User on 10/13/17.
//

import Foundation
import UIKit

extension BillsTableViewController: BillsTableViewControllerProtocol {
    @IBAction func createBillbtnPressed(sender: UIBarButtonItem?) {
        billVCPresenter?.presentNewBill(presenter: self, billEntry: nil)
    }
    
    func editBillEntry(atIndex index: IndexPath) {
        editingIndexPath = index
        billVCPresenter?.presentNewBill(presenter: self, billEntry: dataSource?.entry(at: index))
    }
    
    func deleteBillEntry(atIndex index: IndexPath) {
        guard let entry = dataSource?.entry(at: index) else { return }
        editingIndexPath = index
        deleteBillPresenter?.presentDeleteSheet(presentingVC: self, forBillEntry: entry)
    }
    
    func skipBillEntry(atIndex index: IndexPath) {
        guard let entry = dataSource?.entry(at: index) else { return }
        presenter?.skip(entry: entry)
    }
}
