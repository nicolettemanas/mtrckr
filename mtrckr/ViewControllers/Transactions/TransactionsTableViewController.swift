//
//  TransactionsTableViewController.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit
import Realm
import RealmSwift

protocol TransactionsTableViewControllerProtocol: class {
    var account: Account? { get set }
}

class TransactionsTableViewController: MTTableViewController, TransactionsTableViewControllerProtocol {
    
    private var transactions: Results<Transaction>?
    private var currency: String?
    private var notifToken: NotificationToken?
    private var observer: ObserverProtocol?
    
    var account: Account?
    var transactionDataSource: TransactionsListDataSource?
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
        
        transactionDataSource = TransactionsListDataSource(parentVC: self)
        tableView.delegate = transactionDataSource
        tableView.dataSource = transactionDataSource
        
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
}
