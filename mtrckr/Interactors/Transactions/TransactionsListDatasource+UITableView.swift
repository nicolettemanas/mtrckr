//
//  TransactionsListDatasource+UITableView.swift
//  mtrckr
//
//  Created by User on 11/5/17.
//

import Foundation
import UIKit
import SwipeCellKit

extension TransactionsListDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isFilteringAllAccounts() == false && filterBy != .byAccount {
            guard let header = Bundle.main.loadNibNamed("AccountsFilterHeaderView", owner: self, options: nil)?
                .first as? AccountsFilterHeaderView else { return nil }
            header.sectionHeader.text = getHeader(accounts: accountsFilter)
            return header
        }
        return nil
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filterBy == .byDate || filterBy == .both {
            return nil
        }
        return sectionTitles[section]
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterBy == .byDate || filterBy == .both {
            return transactions?.count ?? 0
        }
        
        return rowsCountSection(section: section)
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if filterBy == .byDate || filterBy == .both {
            if isFilteringAllAccounts() { return 0 }
            return 20
        }
        return 30
    }
    
    /// :nodoc:
    func numberOfSections(in tableView: UITableView) -> Int {
        if filterBy == .byDate || filterBy == .both {
            return 1
        }
        return sectionTitles.count
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell")
            as? TransactionTableViewCell else {
                fatalError("Cannot initialize TransactionTableViewCell")
        }
        
        var t = transactions![indexPath.row]
        if filterBy == .byAccount {
            guard let rows = rowsForSection(section: indexPath.section)
                else { fatalError("Invalid section") }
            t = rows[indexPath.row]
        }
        cell.setValues(ofTransaction: t, withCurrency: currency)
        cell.delegate = delegate as? SwipeTableViewCellDelegate
        return cell
    }
}
