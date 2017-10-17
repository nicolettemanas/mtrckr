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
}

class BillVCPresenter: BillVCPresenterProtocol {
    func presentNewBill(presenter: UIViewController & NewBillViewControllerDelegate, billEntry: BillEntry?) {
        let resolver = MTResolver()
        guard let newBillVC = resolver.container
            .resolve(NewBillViewController.self, arguments: presenter as NewBillViewControllerDelegate, billEntry)
        else { fatalError("NewBillViewControllerDelegate with BillEntry is not registered") }
        
        let nav = UINavigationController(rootViewController: newBillVC)
        presenter.present(nav, animated: true, completion: nil)
    }
    
    func presentPayment(ofBill entry: BillEntry, presenter: UIViewController & PayBillViewControllerDelegate) {
        let resolver = MTResolver()
        guard let payBillVC = resolver.container
            .resolve(PayBillViewController.self, arguments: entry, presenter as PayBillViewControllerDelegate)
        else { fatalError("PayBillViewController with BillEntry is not registered") }
        
        let nav = UINavigationController(rootViewController: payBillVC)
        presenter.present(nav, animated: true, completion: nil)
    }
}
