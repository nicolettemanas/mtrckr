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
    var transTableView: UITableView? { get set }
    var filter: TransactionsFilter! { get set }
    var config: AuthConfig! { get set }
    
    func reloadTableBy(date: Date?, accounts: [Account])
}

class TransactionsTableViewControllerFactory {
    private var storyboard: UIStoryboard
    
    init(with storyboard: UIStoryboard) {
        self.storyboard = storyboard
    }
    
    func createTransactionsTableView(filterBy filter: TransactionsFilter, config: AuthConfig) -> TransactionsTableViewControllerProtocol {
        guard let tvc = self.storyboard.instantiateViewController(withIdentifier: "TransactionsTableViewController")
            as? TransactionsTableViewControllerProtocol else {
                fatalError("TransactionsTableViewController does not conform to protocol TransactionsTableViewControllerProtocol")
        }
        tvc.filter = filter
        tvc.config = config
        return tvc
    }
}

class TransactionsTableViewController: MTTableViewController, TransactionsTableViewControllerProtocol {
    
    private var currency: String?
    private var observer: ObserverProtocol?
    private var emptytransactionDataSource: EmptyTransactionsDataSource?
    private var transactionsDataSource: TransactionsListDataSourceProtocol?
    
    // MARK: - TransactionsTableViewControllerProtocol properties
    internal var accounts: [Account] = []
    internal var date: Date?
    internal var transTableView: UITableView?
    internal var config: AuthConfig!
    internal var filter: TransactionsFilter!
    
    var presenter: TransactionsPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransactionsDatasource()
    }
    
    func setupTransactionsDatasource() {
        transactionsDataSource = TransactionsListDataSource(authConfig: config!,
                                                            delegate: self,
                                                            filterBy: filter!,
                                                            date: date,
                                                            accounts: accounts)
        currency = presenter?.currency()
        
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "TransactionTableViewCell")
        tableView.allowsSelection = false
        
        tableView.delegate = transactionsDataSource
        tableView.dataSource = transactionsDataSource
        
        transTableView = tableView
        
        emptytransactionDataSource = EmptyTransactionsDataSource()
        tableView.emptyDataSetSource = emptytransactionDataSource
        tableView.emptyDataSetDelegate = emptytransactionDataSource
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.separatorColor = MTColors.lightBg
    }
    
    func reloadTableBy(date: Date?, accounts: [Account]) {
        guard let reloadDate = date else {
            transactionsDataSource?.reloadByAccounts(with: accounts)
            return
        }
        
        transactionsDataSource?.reloadByDate(with: reloadDate)
    }
    
    // MARK: - Swipe cell handler methods
    func editTransaction(atIndex index: IndexPath) {
        guard let parentVC = parent as? CalendarViewController,
            let trans = transactionsDataSource?.transaction(at: index) else { return }
        parentVC.editTransaction(transaction: trans)
    }
    
    func confirmDelete(atIndex index: IndexPath) {
        guard let parentVC = parent as? CalendarViewController,
            let trans = transactionsDataSource?.transaction(at: index) else { return }
        parentVC.confirmDeletTransaction(transaction: trans)
    }
}

extension TransactionsTableViewController: TransactionsListDataSourceDelegate {
    func didUpdateTransactions() {
        
    }
    
    func didReceiveChanges(changes: RealmCollectionChange<Results<Transaction>>) {
        tableView.applyChanges(changes: changes)
    }
}
