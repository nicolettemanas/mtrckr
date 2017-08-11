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
    var didPresentId: String?
    
    override func presentTransactions(presentingVC: AccountsTableViewController, dataSource: TransactionsListDataSourceProtocol) {
        didPresent = true
        didPresentId = dataSource.accountsFilter.first?.id
    }
}
