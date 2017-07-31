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

class AccountTransactionsPresenter: AccountTransactionsPresenterProtocol {
    func presentTransactions(ofAccount account: Account, presentingVC: AccountsTableViewController) {
        let transTableFactory = TransactionsTableViewControllerFactory(with: presentingVC.storyboard!)
        let transVC = transTableFactory.createTransactionsTableView(filterBy: .byAccount, config: RealmAuthConfig())
        transVC.accounts = [account]
        guard let vc = transVC as? UIViewController else { return }
        presentingVC.navigationController?.pushViewController(vc, animated: true)
    }
}
