//
//  NewBillPresenterProtocol.swift
//  mtrckr
//
//  Created by User on 8/21/17.
//

import UIKit

protocol BillVCPresenterProtocol {
    func presentNewBill(presenter: UIViewController & NewBillViewControllerDelegate, billEntry: BillEntry?)
    func presentPayment(ofBill entry: BillEntry, presenter: UIViewController & PayBillViewControllerDelegate)
    func presentHistory(ofBill bill: Bill, presenter: UIViewController)
}

/// The event handler for presenting view controllers from `BillsTableViewController`
class BillVCPresenter: BillVCPresenterProtocol {
    
    /// Presents the `NewBillViewController`. Invoked when asked to create a new `Bill` or when asked
    /// to edit a `BillEntry`
    ///
    /// - Parameters:
    ///   - presenter: The `ViewController` presenter that conforms to `NewBillViewControllerDelegate` protocol
    ///   - billEntry: The `BillEntry` associated. Non-nil if asked to edit a `BillEntry`
    func presentNewBill(presenter: UIViewController & NewBillViewControllerDelegate, billEntry: BillEntry?) {
        let resolver = MTResolver()
        guard let newBillVC = resolver.container
            .resolve(NewBillViewController.self, arguments: presenter as NewBillViewControllerDelegate, billEntry)
        else { fatalError("Class not registered") }
        
        let nav = UINavigationController(rootViewController: newBillVC)
        presenter.present(nav, animated: true, completion: nil)
    }
    
    /// Presents the `PayBillViewController`. Invoked when asked to pay an unpaid `BillEntry`
    ///
    /// - Parameters:
    ///   - entry: The `BillEntry` to pay
    ///   - presenter: The `ViewController` presenter that conforms to `PayBillViewControllerDelegate`
    func presentPayment(ofBill entry: BillEntry, presenter: UIViewController & PayBillViewControllerDelegate) {
        let resolver = MTResolver()
        guard let payBillVC = resolver.container
            .resolve(PayBillViewController.self, arguments: entry, presenter as PayBillViewControllerDelegate)
        else { fatalError("Class not registered") }
        
        let nav = UINavigationController(rootViewController: payBillVC)
        presenter.present(nav, animated: true, completion: nil)
    }
    
    /// Presents the `BillHistoryViewController`. Invoked when asked to display the payment history of a `Bill`
    ///
    /// - Parameters:
    ///   - entry: The `Bill` to view the pament history from
    ///   - presenter: The `ViewController` presenter
    func presentHistory(ofBill bill: Bill, presenter: UIViewController) {
        let resolver = MTResolver()
        guard let historyVC = resolver.container
            .resolve(BillHistoryViewController.self, argument: bill)
            else { fatalError("Class not registered") }
        
        presenter.navigationController?.show(historyVC, sender: presenter)
    }
}
