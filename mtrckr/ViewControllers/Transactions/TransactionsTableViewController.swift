//
//  TransactionsTableViewController.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit
import Realm
import RealmSwift
import Swinject

protocol TransactionsTableCellProtocol {
    func editTransaction(transaction: Transaction)
    func confirmDeletTransaction(transaction: Transaction)
}

protocol TransactionsTableViewControllerProtocol: class {
    var transTableView: UITableView? { get set }
    var transactionsDataSource: TransactionsListDataSourceProtocol? { get set }
    var newTransPresenter: NewTransactionPresenterProtocol? { get set }
    var deleteTransactionSheetPresenter: DeleteTransactionSheetPresenterProtocol? { get set }
    var transactionsPresenter: TransactionsPresenterProtocol? { get set }
    var emptytransactionDataSource: EmptyTransactionsDataSource? { get set }
    
    func reloadTableBy(date: Date?, accounts: [Account])
}

class TransactionsTableViewController: MTTableViewController, TransactionsTableViewControllerProtocol {
    
    private var currency: String?
    private var observer: ObserverProtocol?
    
    // MARK: - TransactionsTableViewControllerProtocol properties
    var newTransPresenter: NewTransactionPresenterProtocol?
    var deleteTransactionSheetPresenter: DeleteTransactionSheetPresenterProtocol?
    var transactionsPresenter: TransactionsPresenterProtocol?
    var emptytransactionDataSource: EmptyTransactionsDataSource?
    var transTableView: UITableView?
    var transactionsDataSource: TransactionsListDataSourceProtocol? {
        didSet {
            transactionsDataSource?.delegate = self
        }
    }
    
    // MARK: - Static initializer for dependencies
    static func initWith(dataSource: TransactionsListDataSourceProtocol?,
                         newTransPresenter: NewTransactionPresenterProtocol?,
                         deleteTransPresenter: DeleteTransactionSheetPresenterProtocol?,
                         transactionsPresenter: TransactionsPresenterProtocol?,
                         emptyDataSource: EmptyTransactionsDataSource?) -> TransactionsTableViewController {
        let storyboard = UIStoryboard(name: "Today", bundle: Bundle.main)
        guard let tvc = storyboard.instantiateViewController(withIdentifier: "TransactionsTableViewController")
            as? TransactionsTableViewController else {
                fatalError("TransactionsTableViewController does not conform to protocol TransactionsTableViewControllerProtocol")
        }
        
        tvc.transactionsDataSource = dataSource
        tvc.newTransPresenter = newTransPresenter
        tvc.deleteTransactionSheetPresenter = deleteTransPresenter
        tvc.emptytransactionDataSource = emptyDataSource
        tvc.transactionsPresenter = transactionsPresenter
        
        return tvc
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let resolver = ViewControllerResolvers()
        self.newTransPresenter = resolver.container.resolve(NewTransactionPresenter.self)
        self.deleteTransactionSheetPresenter = resolver.container.resolve(DeleteTransactionSheetPresenter.self)
        self.emptytransactionDataSource = resolver.container.resolve(EmptyTransactionsDataSource.self)
        self.transactionsPresenter = resolver.container.resolve(TransactionsPresenter.self)
        self.transactionsDataSource = resolver.container.resolve(TransactionsListDataSource.self,
                                                                 arguments: TransactionsFilter.byDate, Date())
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTransactionsDatasource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.separatorColor = MTColors.lightBg
    }
    
    // MARK: - Data methods
    func setupTransactionsDatasource() {
        currency = transactionsPresenter?.currency()
        
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "TransactionTableViewCell")
        tableView.allowsSelection = false
        
        tableView.delegate = transactionsDataSource
        tableView.dataSource = transactionsDataSource
        
        transTableView = tableView
        tableView.emptyDataSetSource = emptytransactionDataSource
        tableView.emptyDataSetDelegate = emptytransactionDataSource
    }
    
    func reloadTableBy(date: Date?, accounts: [Account]) {
        if date != nil && accounts.count > 0 {
            transactionsDataSource?.reloadBy(accounts: accounts, date: date!)
        } else if date != nil {
            transactionsDataSource?.reloadByDate(with: date!)
        } else {
            transactionsDataSource?.reloadByAccounts(with: accounts)
        }
    }
    
    // MARK: - Swipe cell handler methods
    func editTransaction(atIndex index: IndexPath) {
        guard let trans = transactionsDataSource?.transaction(at: index) else { return }
        editTransaction(transaction: trans)
    }
    
    func confirmDelete(atIndex index: IndexPath) {
        guard let trans = transactionsDataSource?.transaction(at: index) else { return }
        confirmDeletTransaction(transaction: trans)
    }
}

extension TransactionsTableViewController: TransactionsTableCellProtocol {
    func editTransaction(transaction: Transaction) {
        newTransPresenter?.presentNewTransactionVC(with: transaction, presentingVC: self,
                                                   delegate: self)
    }
    
    func confirmDeletTransaction(transaction: Transaction) {
        deleteTransactionSheetPresenter?.displayDeleteSheet(toDelete: transaction,
                                                            presentingVC: self)
    }
}

extension TransactionsTableViewController: DeleteTransactionSheetPresenterDelegate {
    func shouldDeleteTransaction(transaction: Transaction) {
        transactionsPresenter?.deleteTransaction(transaction: transaction)
    }
}

extension TransactionsTableViewController: NewTransactionViewControllerDelegate {
    func update(transaction: Transaction, withValues name: String, amount: Double, type: TransactionType,
                date: Date, category: Category?, from sourceAcc: Account, to destAccount: Account) {
        transactionsPresenter?.update(transaction: transaction, withValues: name, amount: amount, type: type,
                                      date: date, category: category, from: sourceAcc, to: destAccount)
    }

    func shouldSaveTransaction(with name: String, amount: Double, type: TransactionType, date: Date, category: Category?,
                               from sourceAcc: Account, to destAccount: Account) {
        transactionsPresenter?.createTransaction(with: name, amount: amount, type: type, date: date,
                                                 category: category, from: sourceAcc, to: destAccount)
    }
}

extension TransactionsTableViewController: TransactionsListDataSourceDelegate {
    func didUpdateTransactions() {
        
    }
    
    func didReceiveChanges(changes: RealmCollectionChange<Results<Transaction>>) {
        tableView.applyChanges(changes: changes)
    }
}
