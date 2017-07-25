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
    var transTableView: UITableView? { get set }
    var filterBy: TransactionsFilter? { get set }
}

class TransactionsTableViewController: MTTableViewController, TransactionsTableViewControllerProtocol, TransactionsListDataSourceDelegate {
    
    private var currency: String?
    private var observer: ObserverProtocol?
    private var emptytransactionDataSource: EmptyTransactionsDataSource?
    
    // MARK: - TransactionsTableViewControllerProtocol properties
    internal var accounts: [Account] = []
    internal var date: Date?
    internal var transactionDataSource: TransactionsListDataSourceProtocol?
    internal var transTableView: UITableView?
    internal var filterBy: TransactionsFilter? {
        didSet {
            transactionDataSource?.filterBy = filterBy!
        }
    }
    
    var presenter: TransactionsPresenterProtocol?
    
    internal static func instantiate(with filter: TransactionsFilter) -> TransactionsTableViewController {
        
        guard let transVC: TransactionsTableViewController = UIStoryboard(name: "Today", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "TransactionsTableViewController")
            as? TransactionsTableViewController else {
                fatalError("Cannot find TransactionsTableViewController")
        }
        transVC.filterBy = filter
        transVC.transactionDataSource = TransactionsListDataSource(authConfig: RealmAuthConfig(),
                                                                   delegate: transVC,
                                                                   filterBy: filter)
        return transVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if accounts.count == 1 {
            title = accounts[0].name
        }
        
        currency = presenter?.currency()
        
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "TransactionTableViewCell")
        tableView.allowsSelection = false
        
        if filterBy == nil {
            filterBy = .byAccount
        }
        
        tableView.delegate = transactionDataSource
        tableView.dataSource = transactionDataSource
        transTableView = tableView
        
        emptytransactionDataSource = EmptyTransactionsDataSource()
        tableView.emptyDataSetSource = emptytransactionDataSource
        tableView.emptyDataSetDelegate = emptytransactionDataSource
    }
    
    // MARK: - Swipe cell handler methods
    func editTransaction(atIndex index: IndexPath) {
        guard let parentVC = parent as? TodayViewControllerProtocol,
            let trans = transactionDataSource?.transaction(at: index) else { return }
        parentVC.editTransaction(transaction: trans)
    }
    
    func confirmDelete(atIndex index: IndexPath) {
        guard let parentVC = parent as? TodayViewControllerProtocol,
            let trans = transactionDataSource?.transaction(at: index) else { return }
        parentVC.confirmDeletTransaction(transaction: trans)
    }
    
    // MARK: - TransactionsListDataSourceDelegate
    func didUpdateTransactions() {
        (parent as? TodayViewController)?.calendar.reloadData()
    }
    
    func didReceiveChanges(changes: RealmCollectionChange<Results<Transaction>>) {
        tableView.applyChanges(changes: changes)
    }
}
