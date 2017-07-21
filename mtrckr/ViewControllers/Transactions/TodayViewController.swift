//
//  TodayViewController.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit
import RealmSwift
import FSCalendar
import DZNEmptyDataSet

protocol TodayViewControllerProtocol {
    
}

class TodayViewController: MTViewController, TodayViewControllerProtocol,
    TransactionsTableViewControllerProtocol, NewTransactionViewControllerDelegate,
TransactionsListDataSourceDelegate, UserObserver {
    
    // MARK: - Properties
    var newTransPresenter: NewTransactionPresenterProtocol?
    var transactionsPresenter: TransactionsPresenter?
    var observer: ObserverProtocol?
    
    // MARK: DataSource
    var emptytransactionDataSource: EmptyTransactionsDataSource?
    var calendarDataSource: TransactionsCalendarDataSourceProtocol?
    
    // MARK: TransactionsTableViewControllerProtocol properties
    var accounts: [Account] = []
    var date: Date? = Date()
    var transactionDataSource: TransactionsListDataSourceProtocol?
    
    // MARK: Outlets
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    @IBOutlet weak var transactionsTable: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBAction func newTransactionBtnPressed(_ sender: Any) {
        newTransPresenter?.presentNewTransactionVC(with: nil, presentingVC: self, delegate: self)
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        chartsCollectionView.register(UINib(nibName: "TransactionsChartCollectionViewCell",
//                                            bundle: Bundle.main), forCellWithReuseIdentifier: "TransactionsChartCollectionViewCell")
        transactionsTable.register(UINib(nibName: "TransactionTableViewCell", bundle: Bundle.main),
                                   forCellReuseIdentifier: "TransactionTableViewCell")
        calendar.register(TransactionCalendarCell.self, forCellReuseIdentifier: "cell")
        
        transactionDataSource = TransactionsListDataSource(authConfig: RealmAuthConfig(),
                                                            parentVC: self,
                                                            tableView: transactionsTable,
                                                            filterBy: .byDate)
        transactionDataSource?.delegate = self
        calendarDataSource = TransactionsCalendarDataSource(calendar: calendar,
                                                            transactionsDataSource: transactionDataSource!)
        emptytransactionDataSource = EmptyTransactionsDataSource()
        
        transactionsPresenter = TransactionsPresenter(with: TransactionsInteractor(with: RealmAuthConfig()))
        newTransPresenter = NewTransactionPresenter()
        
        transactionsTable.emptyDataSetSource = emptytransactionDataSource
        transactionsTable.emptyDataSetDelegate = emptytransactionDataSource
        transactionsTable.dataSource = transactionDataSource
        transactionsTable.delegate = transactionDataSource
        transactionsTable.tableFooterView = UIView()
        
        transactionsTable.tableFooterView = UIView()
        calendar.dataSource = calendarDataSource
        calendar.delegate = calendarDataSource
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        
        observer = NotificationObserver()
        observer?.setDidChangeUserBlock {
            DispatchQueue.main.async {
                self.transactionDataSource?.reloadByDate(with: Date())
                self.calendar.reloadData()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: - NewTransactionViewControllerDelegate methods
    func shouldSaveTransaction(with name: String, amount: Double, type: TransactionType, date: Date, category: Category?,
                               from sourceAcc: Account, to destAccount: Account) {
        transactionsPresenter?.createTransaction(with: name, amount: amount, type: type, date: date,
                                                 category: category, from: sourceAcc, to: destAccount)
    }
    
    // MARK: - TransactionsListDataSourceDelegate
    func didUpdateTransactions() {
        calendar.reloadData()
    }
    
    func editTransaction(transaction: Transaction) {
        
    }
    
    func confirmDeletTransaction(transaction: Transaction) {
        
    }
}
