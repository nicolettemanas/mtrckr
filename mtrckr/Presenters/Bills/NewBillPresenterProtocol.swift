//
//  NewBillPresenterProtocol.swift
//  mtrckr
//
//  Created by User on 8/21/17.
//

import UIKit

protocol NewBillPresenterDelegate: class {
    func proceedEditEntry(atIndex indexPath: IndexPath)
    func proceedEditProceedingEntries(ofBillAtIndexPath index: IndexPath, fromDate date: Date)
}

protocol PayBillPresenterDelegate: class {
    func proceedPayment(ofBill entry: BillEntry, amount: Double, account: Account, date: Date)
}

protocol BillVCPresenterProtocol {
    func presentNewBill(presenter: NewBillViewControllerDelegate, billEntry: BillEntry?)
    func presentPayment(ofBill entry: BillEntry, presenter: PayBillPresenterDelegate)
}

class BillVCPresenter: BillVCPresenterProtocol {
    func presentNewBill(presenter: NewBillViewControllerDelegate, billEntry: BillEntry?) {

        guard let nav = UIStoryboard.init(name: "Bills", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "NewBillNavigationVController") as? UINavigationController else {
            fatalError("Cannot find NewBillNavigationVController")
        }
        
        guard let newBillVC = nav.topViewController as? NewBillViewController else {
            fatalError("Wrong root viewcontroller")
        }
        
        newBillVC.delegate = presenter
        newBillVC.billEntry = billEntry
        (presenter as? UIViewController)?.present(nav, animated: true, completion: nil)
    }
    
    func presentPayment(ofBill entry: BillEntry, presenter: PayBillPresenterDelegate) {
        
    }
}
