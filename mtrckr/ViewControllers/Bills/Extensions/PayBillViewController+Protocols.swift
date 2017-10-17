//
//  PayBillViewController+Protocols.swift
//  mtrckr
//
//  Created by User on 10/14/17.
//

import Foundation
import UIKit

protocol PayBillViewControllerProtocol {
    func payBill(amount: Double, date: Date, account: Account)
    func dismiss()
}

extension PayBillViewController: PayBillViewControllerProtocol {
    @IBAction func payBill(sender: UIBarButtonItem?) {
        guard form.validate().isEmpty else { return }
        payBill(amount  : payRow.value!,
                date    : dateRow.value!,
                account : accountRow.value!)
        dismiss()
    }
    
    @IBAction func cancel(sender: UIBarButtonItem?) {
        dismiss()
    }
    
    func payBill(amount: Double, date: Date, account: Account) {
        guard let payEntry = entry else { fatalError("Entry must not be nil") }
        delegate?
            .proceedPayment(ofBill  : payEntry,
                            amount  : amount,
                            account : account,
                            date    : date)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
