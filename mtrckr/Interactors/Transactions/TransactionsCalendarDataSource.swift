//
//  TransactionsCalendarDataSource.swift
//  mtrckr
//
//  Created by User on 7/18/17.
//

import UIKit
import JTAppleCalendar
import RealmSwift

protocol TransactionsCalendarDataSourceDelegate: class {
    func didScrollto(dateSegmentWith visibleDates: DateSegmentInfo)
    func didReceiveChanges(changes: RealmCollectionChange<Results<Transaction>>)
    func didSelect(date: Date)
}

protocol TransactionsCalendarDataSourceProtocol: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func reloadCalendar(with accounts: [Account], initialDate: Date)
    func reloadDates(dates: [Date])
    func allAccounts() -> [Account]
}

class TransactionsCalendarDataSource: RealmHolder, TransactionsCalendarDataSourceProtocol {
    weak var calendar: JTAppleCalendarView?
    weak var delegate: TransactionsCalendarDataSourceDelegate?
    
    var transactions: Results<Transaction>?
    var transactionDict: [Date: (String, String)] = [:]
    
    var notificationToken: NotificationToken?

    init(calendar cal: JTAppleCalendarView, delegate del: TransactionsCalendarDataSourceDelegate, initialMonth: Date) {
        super.init(with: RealmAuthConfig())
        calendar = cal
        delegate = del
        setupTransactions(initialDate: initialMonth, accounts: [])
    }
    
    func setupTransactions(initialDate: Date, accounts: [Account]) {
        let startDate = initialDate.subtract(3.months)
        let endDate = initialDate.add(3.months)
        self.transactions = Transaction.all(in: self.realmContainer!.userRealm!, between: startDate.start(of: .month),
                                            and: endDate.end(of: .month), inAccounts: accounts)
        self.notificationToken = self.transactions?.observe({ [weak self] collectionChange in
            if let strongSelf = self {
                strongSelf.delegate?.didReceiveChanges(changes: collectionChange)
            }
        })
    }
    
    func reloadDates(dates: [Date]) {
        for date in dates {
            let safeTransactions = ThreadSafeReference(to: self.transactions!)
            DispatchQueue.global(qos: .background).async {
                let resolvedTransactions: Results<Transaction>? = self.realmContainer!.userRealm!.resolve(safeTransactions)
                let filteredTransactions: Results<Transaction>? = self.filter(transactions: resolvedTransactions, for: date)
                let transSum = self.sum(of: filteredTransactions)
                self.transactionDict[date.start(of: .day)] = transSum
                DispatchQueue.main.async {
                    self.calendar?.reloadDates(dates)
                }
            }
        }
    }
    
    func reloadCalendar(with accounts: [Account], initialDate: Date) {
        self.transactionDict = [:]
        setupTransactions(initialDate: initialDate, accounts: accounts)
        self.calendar?.reloadData()
    }
    
    func allAccounts() -> [Account] {
        return Array(Account.all(in: self.realmContainer!.userRealm!))
    }
    
    func sum(of transactions: Results<Transaction>?) -> (String, String) {
        guard let trans = transactions else { return ("", "") }
        
        var expenses: Double = 0
        var income: Double = 0
        let currency = realmContainer!.currency()
        
        for tran in trans {
            
            if tran.type == TransactionType.expense.rawValue {
                expenses += tran.amount
            } else if tran.type == TransactionType.income.rawValue {
                income += tran.amount
            }
        }
        
        return (expenses > 0 ? (NumberFormatter.currencyKString(withCurrency: currency, amount: expenses) ?? "") : "",
                income > 0 ? (NumberFormatter.currencyKString(withCurrency: currency, amount: income) ?? "") : "")
    }
        
    func filter(transactions: Results<Transaction>?, for date: Date) -> Results<Transaction>? {
        return transactions?.filter("transactionDate >= %@ AND transactionDate <= %@",
                                     date.start(of: .day),
                                     date.end(of: .day))
    }
}

extension TransactionsCalendarDataSource: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let parameters = ConfigurationParameters(startDate: Date().start(of: .year),
                                                 endDate: Date().end(of: .year),
                                                 numberOfRows: 6, calendar: Calendar.current,
                                                 generateInDates: InDateCellGeneration.forAllMonths,
                                                 generateOutDates: OutDateCellGeneration.tillEndOfGrid,
                                                 firstDayOfWeek: DaysOfWeek.sunday,
                                                 hasStrictBoundaries: true)
        return parameters
    }
}

extension TransactionsCalendarDataSource: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView,
                  willDisplay cell: JTAppleCell,
                  forItemAt date: Date,
                  cellState: CellState,
                  indexPath: IndexPath) {
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  cellForItemAt date: Date,
                  cellState: CellState,
                  indexPath: IndexPath) -> JTAppleCell {
        
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "customCalendarCell", for: indexPath)
            as? CustomCalendarCell else { fatalError("Cannot find cell with identifier customCalendarCell") }
        cell.dateLabel.text = cellState.text
        cell.configureCell(cellState: cellState)
        
        if let transSum = transactionDict[date] {
            cell.expensesLabel.text = transSum.0
            cell.incomeLabel.text = transSum.1
        } else {
            if let trans = self.transactions {
                let threadSafeTransactions = ThreadSafeReference(to: trans)
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool(invoking: {
                        let resolvedTransactions = self.realmContainer!.userRealm!.resolve(threadSafeTransactions)
                        let transactionsForDate = resolvedTransactions!
                            .filter("transactionDate >= %@ AND transactionDate <= %@",
                                    date.start(of: .day), date.end(of: .day))
                        let transSum = self.sum(of: transactionsForDate)
                        self.transactionDict[date] = transSum
                        DispatchQueue.main.async {
                            cell.expensesLabel.text = transSum.0
                            cell.incomeLabel.text = transSum.1
                        }
                    })
                }
            }
        }
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didSelectDate date: Date,
                  cell: JTAppleCell?,
                  cellState: CellState) {
        
        guard let validCell = cell as? CustomCalendarCell else { return }
        print("Didselect cell date \(date)")
        calendar.visibleDates({ [unowned self] datesInfo in
            if datesInfo.monthDates.first?.date.month != date.month {
                self.calendar?.scrollToDate(date)
                print("Scroll to \(date)")
            } else {
                print("Configure cell \(date)")
                validCell.configureCell(cellState: cellState)
            }
        })
        delegate?.didSelect(date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didDeselectDate date: Date,
                  cell: JTAppleCell?,
                  cellState: CellState) {
        
        guard let validCell = cell as? CustomCalendarCell else { return }
        validCell.configureCell(cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        let date = (visibleDates.monthDates[5].date)
        print("Did scroll to \(date)")
        setupTransactions(initialDate: date, accounts: [])
        delegate?.didScrollto(dateSegmentWith: visibleDates)
        print("Will select \(visibleDates.monthDates[5].date)")
        calendar.selectDates([date], triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
    }
}
