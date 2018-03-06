//
//  AccountsTableViewController+Datasource.swift
//  mtrckr
//
//  Created by User on 11/5/17.
//

import Foundation
import UIKit

extension AccountsTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell")
            as? AccountTableViewCell else {
            fatalError("Cannot initialize AccountTableViewCell")
        }

        let a = accounts![indexPath.row]
        cell.setValues(ofAccount: a, withCurrency: currency!)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .top)
            self.deleteAccount(atIndex: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = self.transactionsDataSource,
            let accnts = self.accounts else { return }
        dataSource.accountsFilter = [accnts[indexPath.row]]
        self.transactionsPresenter?.presentTransactions(presentingVC: self, dataSource: dataSource)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
