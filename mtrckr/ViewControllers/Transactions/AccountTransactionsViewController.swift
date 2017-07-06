//
//  AccountTransactionsViewController.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit

protocol AccountTransactionsViewControllerProtocol {
    var account: Account? { get set }
}

class AccountTransactionsViewController: MTTableViewController, AccountTransactionsViewControllerProtocol {
    var account: Account?
//    var transactions: Results<Transaction>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UITableView delegate and datasource methods
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return transactions.count
//    }
}
