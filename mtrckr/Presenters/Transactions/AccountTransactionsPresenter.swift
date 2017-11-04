//
//  TransactionsPresenter.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit

protocol AccountTransactionsPresenterProtocol {
    func presentTransactions(presentingVC: AccountsTableViewController, dataSource: TransactionsListDataSourceProtocol)
}

/// Class responsible for presenting `TransactionsTableViewController`
class AccountTransactionsPresenter: AccountTransactionsPresenterProtocol {
    
    /// Presents `TransactionsTableViewController` with a given `Account` filter
    ///
    /// - Parameters:
    ///   - account: An array of `Accounts` where to fetch the `Transactions` from
    ///   - presentingVC: The presenting `ViewController`
    func presentTransactions(presentingVC: AccountsTableViewController, dataSource: TransactionsListDataSourceProtocol) {
        guard let transVC = MTResolver().container.resolve(TransactionsTableViewController.self, argument: dataSource) else {
            fatalError("Cannot resolve transactionTableViewController")
        }
        
        transVC.transactionsDataSource?.reloadByAccounts(with: dataSource.accountsFilter)
        presentingVC.navigationController?.pushViewController(transVC, animated: true)
    }
}
