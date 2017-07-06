//
//  TransactionsPresenter.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit

protocol AccountTransactionsPresenterProtocol {
    func presentTransactions(ofAccount account: Account, presentingVC: MTAccountsTableViewController)
}

class AccountTransactionsPresenter: AccountTransactionsPresenterProtocol {
    func presentTransactions(ofAccount account: Account, presentingVC: MTAccountsTableViewController) {
        let nav = UIStoryboard(name: "Accounts", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "TransactionsNavigationController")
        guard let vc = (nav as? UINavigationController)?.topViewController
            as? TransactionsTableViewController else {
                return
        }
        
        vc.account = account
        presentingVC.navigationController?.pushViewController(vc, animated: true)
    }
}
