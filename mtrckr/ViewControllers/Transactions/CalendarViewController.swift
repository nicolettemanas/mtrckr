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
    func shouldDeleteTransaction(transaction: Transaction)
    var deleteTransactionSheetPresenter: DeleteTransactionSheetPresenterProtocol? { get set }
}

class CalendarViewController: MTViewController {

    // MARK: - IBOutlets/IBActions
    @IBOutlet weak var calendar: JTAppleCalendarView!
    @IBOutlet weak var monthyearLabel: UILabel!
    @IBOutlet weak var transactionsTableContainer: UIView!

    @IBAction func didPressFilter(sender: UIButton) {
        guard let dataSource = calendarDataSource else { fatalError("CalendarDataSource is nil") }
        filterPresenter?.presentSelection(accounts: dataSource.allAccounts(), presentingVC: self)
    }

    var observer: ObserverProtocol?
    var transactionsTableVC: TransactionsTableViewControllerProtocol?
    var calendarDataSource: TransactionsCalendarDataSourceProtocol?
    var filterPresenter: AccountsFilterPresenterProtocol?
    var accounts = [Account]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        setupTransactionsTable()
        setupObserver()
        setupCalendarDataSource()
    }

    // MARK: - Setup methods
    func setupCalendarView() {
        calendar.minimumLineSpacing = 0
        calendar.minimumInteritemSpacing = 0
        calendar.allowsMultipleSelection = false
        calendar.cellSize = 0
        setupVisibleDates()
        calendar
            .scrollToDate(Date(),
                          triggerScrollToDateDelegate   : false,
                          animateScroll                 : false,
                          preferredScrollPosition       : .left,
                          extraAddedOffset              : 0,
                          completionHandler             : nil)
    }

    func setupTransactionsTable() {
        let dataSource: TransactionsListDataSourceProtocol
            = MTResolver.shared.transactions.resolve(TransactionsListDataSource.self, arguments: TransactionsFilter.byDate, Date())!
        if let transVC = MTResolver.shared.transactions.resolve(TransactionsTableViewController.self, argument: dataSource) {
            transactionsTableVC = transVC
            transVC.view.frame = transactionsTableContainer.bounds
            addChildViewController(transVC)
            transactionsTableContainer.addSubview(transVC.view)
            transVC.didMove(toParentViewController: self)
        }
    }

    func setupCalendarDataSource() {
        calendarDataSource = TransactionsCalendarDataSource(calendar    : calendar,
                                                            delegate    : self,
                                                            initialMonth: Date())
        calendar.ibCalendarDataSource = calendarDataSource
        calendar.ibCalendarDelegate = calendarDataSource
        filterPresenter = AccountsFilterPresenter()
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
}

extension CalendarViewController: TransactionsCalendarDataSourceDelegate {
    func didScrollto(dateSegmentWith visibleDates: DateSegmentInfo) {
        setupVisibleDates()
    }

    func didReceiveChanges(changes: RealmCollectionChange<Results<Transaction>>) {
        switch changes {
        case .initial:
            calendar.reloadData()
        case .update(let updates, let deletions, _, _):
            var datesToReload: [Date] = []
            var startDates: [Date] = []
            for trans in updates {
                print("Updated: \(trans.id) \(trans.transactionDate)")
                if !startDates.contains(trans.transactionDate.start(of: .day)) {
                    datesToReload.append(trans.transactionDate)
                    startDates.append(trans.transactionDate.start(of: .day))
                }
            }
            print("dates to reload: \(datesToReload)")
            if datesToReload.isEmpty && !deletions.isEmpty {
                calendar.reloadData()
            } else {
                calendarDataSource?.reloadDates(dates: datesToReload)
            }
        case .error(let error): fatalError("\(error)")
        }
    }

    func didSelect(date: Date) {
        transactionsTableVC?.reloadTableBy(date: date, accounts: accounts)
    }
}

extension CalendarViewController: AccountsFilterViewControllerDelegate {
    func didSelectAccounts(accounts: [Account]) {
        self.accounts = accounts
        self.calendarDataSource?.reloadCalendar(with: accounts, initialDate: Date())
        self.transactionsTableVC?.reloadTableBy(date: Date(), accounts: accounts)
    }
}
