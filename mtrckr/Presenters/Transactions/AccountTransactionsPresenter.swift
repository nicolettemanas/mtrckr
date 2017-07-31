//
//  TransactionsPresenter.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit

protocol AccountTransactionsPresenterProtocol {
    func presentTransactions(ofAccount account: Account, presentingVC: AccountsTableViewController)
}

/// Class responsible for presenting `TransactionsTableViewController`
class AccountTransactionsPresenter: AccountTransactionsPresenterProtocol {
    
    /// Presents `TransactionsTableViewController` with a given `Account` filter
    ///
    /// - Parameters:
    ///   - account: The `Account` where to fetch the `Transactions` from
    ///   - presentingVC: The presenting `ViewController`
    func presentTransactions(ofAccount account: Account, presentingVC: AccountsTableViewController) {
        let transTableFactory = TransactionsTableViewControllerFactory(with: presentingVC.storyboard!)
        let transVC = transTableFactory.createTransactionsTableView(filterBy: .byAccount, config: RealmAuthConfig())
        transVC.accounts = [account]
        guard let vc = transVC as? UIViewController else { return }
        presentingVC.navigationController?.pushViewController(vc, animated: true)
    }
}
