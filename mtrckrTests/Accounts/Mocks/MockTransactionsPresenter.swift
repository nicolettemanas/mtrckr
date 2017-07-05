//
//  MockTransactionsPresenter.swift
//  mtrckrTests
//
//  Created by User on 7/5/17.
//

import UIKit
@testable import mtrckr

class MockTransactionsPresenter: TransactionsPresenter {
    var didPresent = false
    var didPresentId = ""
    override func presentTransactions(ofAccount account: Account, presentingVC: MTAccountsTableViewController) {
        didPresent = true
        didPresentId = account.id
    }
}
