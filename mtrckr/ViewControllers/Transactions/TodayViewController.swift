//
//  TodayViewController.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit
import RealmSwift
//import FSCalendar
import DZNEmptyDataSet

protocol TodayViewControllerProtocol {
    func editTransaction(transaction: Transaction)
    func confirmDeletTransaction(transaction: Transaction)
    func shouldDeleteTransaction(transaction: Transaction)
    
    var deleteTransactionSheetPresenter: DeleteTransactionSheetPresenterProtocol? { get set }
}

class TodayViewController: MTViewController/*, TodayViewControllerProtocol,
NewTransactionViewControllerDelegate, UserObserver*/ {
    
    // MARK: - Properties
    var newTransPresenter: NewTransactionPresenterProtocol?
    var transactionsPresenter: TransactionsPresenter?
    var observer: ObserverProtocol?
    var transactionsTableVC: TransactionsTableViewControllerProtocol?
    
    // MARK: DataSource
//    var calendarDataSource: TransactionsCalendarDataSourceProtocol?
    
    // MARK: TodayViewControllerProtocol
    var deleteTransactionSheetPresenter: DeleteTransactionSheetPresenterProtocol?
    
    // MARK: Outlets
    @IBOutlet weak var chartsCollectionView: UICollectionView!
//    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var transactionsTableContainer: UIView!
    
    @IBAction func newTransactionBtnPressed(_ sender: Any) {
//        newTransPresenter?.presentNewTransactionVC(with: nil, presentingVC: self, delegate: self)
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        observer = NotificationObserver()
        observer?.setDidChangeUserBlock {
            DispatchQueue.main.async {
//                self.calendar.reloadData()
            }
        }
        
//        setupTransactionsTable()
//        setupCalendar()
    }
    
//    func setupCalendar() {
//        guard transactionsTableVC != nil else { return }
//        calendarDataSource = TransactionsCalendarDataSource(calendar: calendar,
//                                                            transactionsDataSource: transactionsTableVC!.transactionDataSource!)
//        calendar.register(TransactionCalendarCell.self, forCellReuseIdentifier: "cell")
//        calendar.dataSource = calendarDataSource
//        calendar.delegate = calendarDataSource
//        calendar.clipsToBounds = true
//        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
//    }
    
//    func setupTransactionsTable() {
//
//        let transVC = TransactionsTableViewController.instantiate(with: .byDate)
//        transVC.view.frame = transactionsTableContainer.bounds
//        transactionsTableVC = transVC
//        addChildViewController(transVC)
//        transactionsTableContainer.addSubview(transVC.view)
//        transVC.didMove(toParentViewController: self)
//
//        newTransPresenter = NewTransactionPresenter()
//        deleteTransactionSheetPresenter = DeleteTransactionSheetPresenter()
//        transactionsPresenter = TransactionsPresenter(with: TransactionsInteractor(with: RealmAuthConfig()))
//    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: - NewTransactionViewControllerDelegate methods
//    func shouldSaveTransaction(with name: String, amount: Double, type: TransactionType, date: Date, category: Category?,
//                               from sourceAcc: Account, to destAccount: Account) {
//        transactionsPresenter?.createTransaction(with: name, amount: amount, type: type, date: date,
//                                                 category: category, from: sourceAcc, to: destAccount)
//    }
//
//    // MARK: - TodayViewControllerProtocol
//    func shouldDeleteTransaction(transaction: Transaction) {
//        transactionsPresenter?.deleteTransaction(transaction: transaction)
//    }
//
//    func editTransaction(transaction: Transaction) {
//        newTransPresenter?.presentNewTransactionVC(with: transaction, presentingVC: self,
//                                                   delegate: self)
//    }
//
//    func confirmDeletTransaction(transaction: Transaction) {
//        deleteTransactionSheetPresenter?.displayDeleteSheet(toDelete: transaction,
//                                                            presentingVC: self)
//    }
}
