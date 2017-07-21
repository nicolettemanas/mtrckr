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
        let nav = UIStoryboard(name: "Accounts", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "TransactionsNavigationController")
        guard let vc = (nav as? UINavigationController)?.topViewController
            as? TransactionsTableViewController else {
                return
        }
        
        vc.accounts = [account]
        presentingVC.navigationController?.pushViewController(vc, animated: true)
    }
}
