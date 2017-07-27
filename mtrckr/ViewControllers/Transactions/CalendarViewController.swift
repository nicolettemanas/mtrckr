//
//  CalendarViewController.swift
//  mtrckr
//
//  Created by User on 7/25/17.
//

import UIKit
import JTAppleCalendar
import DateToolsSwift
import RealmSwift

protocol CalendarViewControllerProtocol {
    func editTransaction(transaction: Transaction)
    func confirmDeletTransaction(transaction: Transaction)
    func shouldDeleteTransaction(transaction: Transaction)
    
    var deleteTransactionSheetPresenter: DeleteTransactionSheetPresenterProtocol? { get set }
}

class CalendarViewController: MTViewController {
    
    @IBOutlet weak var calendar: JTAppleCalendarView!
    @IBOutlet weak var monthyearLabel: UILabel!
    @IBOutlet weak var transactionsTableContainer: UIView!
    
    var newTransPresenter: NewTransactionPresenterProtocol?
    var transactionsPresenter: TransactionsPresenter?
    var deleteTransactionSheetPresenter: DeleteTransactionSheetPresenterProtocol?
    
    var observer: ObserverProtocol?
    var transactionsTableVC: TransactionsTableViewControllerProtocol?

    var calendarDataSource: TransactionsCalendarDataSourceProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        setupTransactionsTable()
        setupObserver()
//        setupTrasactionDataSource()
        setupCalendarDataSource()
    }
    
    // MARK: - Setup methods
    func setupCalendarView() {
        calendar.minimumLineSpacing = 0
        calendar.minimumInteritemSpacing = 0
        calendar.allowsMultipleSelection = false
        calendar.cellSize = 0
        setupVisibleDates()
        calendar.scrollToDate(Date(),
                              triggerScrollToDateDelegate: false,
                              animateScroll: false,
                              preferredScrollPosition: .left,
                              extraAddedOffset: 0,
                              completionHandler: nil)
    }
    
    func setupTransactionsTable() {
        let transTableViewFactory = TransactionsTableViewControllerFactory(with: self.storyboard!)
        if let transVC = transTableViewFactory.createTransactionsTableView(filterBy: .byDate,
                                                                           config: RealmAuthConfig())
            as? TransactionsTableViewController {
            transVC.view.frame = transactionsTableContainer.bounds
            transactionsTableVC = transVC
            addChildViewController(transVC)
            transactionsTableContainer.addSubview(transVC.view)
            transVC.didMove(toParentViewController: self)
        }
        
        newTransPresenter = NewTransactionPresenter()
        deleteTransactionSheetPresenter = DeleteTransactionSheetPresenter()
        transactionsPresenter = TransactionsPresenter(with: TransactionsInteractor(with: RealmAuthConfig()))
    }
    
    func setupCalendarDataSource() {
        calendarDataSource = TransactionsCalendarDataSource(calendar: calendar,
                                                            delegate: self,
                                                            initialMonth: Date())
        calendar.ibCalendarDataSource = calendarDataSource
        calendar.ibCalendarDelegate = calendarDataSource
    }
    
    func setupVisibleDates() {
        calendar.visibleDates { [unowned self] dates in
            guard let date = dates.monthDates.first?.date else { return }
            self.monthyearLabel.text = date.format(with: "MMMM yyyy")
        }
    }
    
    func setupObserver() {
        observer = NotificationObserver()
        observer?.setDidChangeUserBlock {
            DispatchQueue.main.async {
                self.calendar.reloadData()
            }
        }
    }
    
//    func setupTrasactionDataSource() {
//        transactionDataSource = TransactionsListDataSource(authConfig: RealmAuthConfig(),
//                                                           delegate: nil,
//                                                           filterBy: .byDate)
//    }
}

extension CalendarViewController: NewTransactionViewControllerDelegate {
    func shouldSaveTransaction(with name: String, amount: Double, type: TransactionType, date: Date, category: Category?,
                               from sourceAcc: Account, to destAccount: Account) {
        transactionsPresenter?.createTransaction(with: name, amount: amount, type: type, date: date,
                                                 category: category, from: sourceAcc, to: destAccount)
    }
}

extension CalendarViewController: CalendarViewControllerProtocol {
    func shouldDeleteTransaction(transaction: Transaction) {
        transactionsPresenter?.deleteTransaction(transaction: transaction)
    }
    
    func editTransaction(transaction: Transaction) {
        newTransPresenter?.presentNewTransactionVC(with: transaction, presentingVC: self,
                                                   delegate: self)
    }
    
    func confirmDeletTransaction(transaction: Transaction) {
        deleteTransactionSheetPresenter?.displayDeleteSheet(toDelete: transaction,
                                                            presentingVC: self)
    }
}

extension CalendarViewController: TransactionsCalendarDataSourceDelegate {
    func didScrollto(dateSegmentWith visibleDates: DateSegmentInfo) {
        setupVisibleDates()
    }
    
    func didReceiveChanges(changes: RealmCollectionChange<Results<Transaction>>) {
        switch changes {
        case .initial:
            calendar.reloadData()
            break
        case .update(let updates, _, _, _):
            var datesToReload: [Date] = []
            for trans in updates {
                if !datesToReload.contains(trans.transactionDate.start(of: .day)) {
                    datesToReload.append(trans.transactionDate.start(of: .day))
                }
            }
            print("dates to reload: \(datesToReload)")
            calendarDataSource?.reloadDates(dates: datesToReload)
        case .error(let error): fatalError("\(error)")
        }
    }
    
    func didSelect(date: Date) {
        transactionsTableVC?.reloadTableBy(date: date, accounts: [])
    }
}
