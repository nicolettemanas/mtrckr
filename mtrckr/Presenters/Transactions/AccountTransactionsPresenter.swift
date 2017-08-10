//
//  TransactionsPresenter.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit

protocol AccountTransactionsPresenterProtocol {
    func presentTransactions(presentingVC: AccountsTableViewController)
}

/// Class responsible for presenting `TransactionsTableViewController`
class AccountTransactionsPresenter: AccountTransactionsPresenterProtocol {
    
    /// Presents `TransactionsTableViewController` with a given `Account` filter
    ///
    /// - Parameters:
    ///   - account: The `Account` where to fetch the `Transactions` from
    ///   - presentingVC: The presenting `ViewController`
    func presentTransactions(presentingVC: AccountsTableViewController) {
        
        guard let transVC = ViewControllerResolvers().transactionTableViewController(filterType: .byAccount) else {
            fatalError("Cannot resolve transactionTableViewController with name byAccount")
        }
        presentingVC.navigationController?.pushViewController(transVC, animated: true)
    }
}
