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
    var accounts: [Account] { get set }
    var date: Date? { get set }
    var transactionDataSource: TransactionsListDataSourceProtocol? { get set }
}

class TransactionsTableViewController: MTTableViewController, TransactionsTableViewControllerProtocol {
    private var currency: String?
    private var observer: ObserverProtocol?
    
    // MARK: - TransactionsTableViewControllerProtocol properties
    internal var accounts: [Account] = []
    internal var date: Date?
    internal var transactionDataSource: TransactionsListDataSourceProtocol?
    
    var presenter: TransactionsPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if accounts.count == 1 {
            title = accounts[0].name
        }
        
        currency = presenter?.currency()
        
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "TransactionTableViewCell")
        tableView.allowsSelection = false
        
        transactionDataSource = TransactionsListDataSource(authConfig: RealmAuthConfig(), parentVC: self, tableView: tableView, filterBy: .byAccount)
        tableView.delegate = transactionDataSource
        tableView.dataSource = transactionDataSource
        
//        if accounts.count > 0 { setupResults() }
    }
    
//    func setupResults() {
//        DispatchQueue.main.async {
//            self.transactions = self.presenter?.transactions(fromAccounts: self.accounts)
//            self.notifToken = self.transactions?.addNotificationBlock(self.tableView.applyChanges)
//            self.tableView.reloadData()
//        }
//    }
    
    // MARK: - Swipe cell handler methods
//    func editTransaction(atIndex: IndexPath) {
//
//    }
    
//    func confirmDelete(atIndex: IndexPath) {
//
//    }
}
