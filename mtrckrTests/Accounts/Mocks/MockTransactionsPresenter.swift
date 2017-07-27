//
//  MockTransactionsPresenter.swift
//  mtrckrTests
//
//  Created by User on 7/5/17.
//

import UIKit
@testable import mtrckr

class MockTransactionsPresenter: TransactionsPresenter {
    var didCreate = false
    var name: String?
    var amount: Double?
    var type: TransactionType?
    var date: Date?
    var categoty: mtrckr.Category?
    var from: Account?
    var to: Account?
    
    override func createTransaction(with name: String, amount: Double, type: TransactionType, date: Date,
                                    category: mtrckr.Category?, from sourceAcc: Account, to destAccount: Account) {
        didCreate = true
        self.name = name
        self.amount = amount
        self.type = type
        self.date = date
        self.categoty = category
        self.from = sourceAcc
        self.to = destAccount
    }
}
