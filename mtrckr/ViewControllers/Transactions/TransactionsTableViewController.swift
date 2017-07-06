//
//  TransactionsTableViewController.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit
import Realm
import RealmSwift

protocol TransactionsTableViewControllerProtocol {
    var account: Account? { get set }
}

class TransactionsTableViewController: MTTableViewController, TransactionsTableViewControllerProtocol {
    var account: Account?
    var transactions: Results<Transaction>?
    var currency: String?
    var notifToken: NotificationToken?
    var observer: ObserverProtocol?
    
    var presenter: TransactionsPresenterProtocol?
    
    deinit {
        notifToken?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = account?.name
        currency = presenter?.currency()
        
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "TransactionTableViewCell")
        tableView.allowsSelection = false
        
        if account != nil { setupResults() }
    }
    
    func setupResults() {
        DispatchQueue.main.async {
            self.transactions = self.presenter?.transactions(fromAccount: self.account!)
            self.notifToken = self.transactions?.addNotificationBlock(self.tableView.applyChanges)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Swipe cell handler methods
    func editTransaction(atIndex: IndexPath) {
        
    }
    
    func confirmDelete(atIndex: IndexPath) {
        
    }
    
    // MARK: - UITableView delegate and datasource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as? TransactionTableViewCell else {
            fatalError("Cannot initialize TransactionTableViewCell")
        }
        
        let t = transactions![indexPath.row]
        cell.setValues(ofTransaction: t, withCurrency: currency!)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return transactions?.count ?? 0
    }
}
