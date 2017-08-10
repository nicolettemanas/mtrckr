//
//  MockAccountTransactionsPresenter.swift
//  mtrckrTests
//
//  Created by User on 7/27/17.
//

import UIKit
@testable import mtrckr

class MockAccountTransactionsPresenter: AccountTransactionsPresenter {
    var didPresent = false
    
    override func presentTransactions(presentingVC: AccountsTableViewController) {
        didPresent = true
    }
}
