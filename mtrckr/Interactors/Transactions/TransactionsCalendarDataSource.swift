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
    func reloadDates(dates: [Date])
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
        
        self.transactions = Transaction.all(in: self.realmContainer!.userRealm!, between: initialMonth.start(of: .month),
                                       and: initialMonth.end(of: .month), inAccounts: [])
        self.notificationToken = self.transactions?.addNotificationBlock({ [unowned self] collectionChange in
            self.delegate?.didReceiveChanges(changes: collectionChange)
        })
    }
    
    
    func reloadDates(dates: [Date]) {
        for date in dates {
            let safeTransactions = ThreadSafeReference(to: self.transactions!)
            DispatchQueue.global(qos: .background).async {
                let resolvedTransactions: Results<Transaction>? = self.realmContainer!.userRealm!.resolve(safeTransactions)
                let filteredTransactions: Results<Transaction>? = self.filter(transactions: resolvedTransactions, for: date)
                let transSum = self.sum(of: filteredTransactions)
                self.transactionDict[date] = transSum
                DispatchQueue.main.async {
                    self.calendar?.reloadDates(dates)
                }
            }
        }
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
    
//
//    // MARK: - FSCalendarDelegate methods
//    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
//        return nil
////        return transactionsDataSource?.sumOfDate(date: date, account: []).0
//    }
//
//    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
////        configure(cell: cell, for: date, at: monthPosition)
//    }
//
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        transactionsDataSource?.reloadByDate(with: date)
//        configureCells()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        configureCells()
//    }
//
//    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
//        guard let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as? TransactionCalendarCell
//            else { fatalError("TransactionCalendarCell not registered") }
//        return cell
//    }
//
//    // MARK: - Private calendar methods
//    private func configureCells() {
//        calendar?.visibleCells().forEach { (cell) in
//            guard   let date = calendar?.date(for: cell),
//                    let position = calendar?.monthPosition(for: cell) else { return }
//            self.configure(cell: cell, for: date, at: position)
//        }
//    }
//
//    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
//        guard let customCell = (cell as? TransactionCalendarCell) else { return }
//        if customCell.isSelected {
//            customCell.customSelectionView.isHidden = false
//        } else {
//            customCell.customSelectionView.isHidden = true
//        }
//
//        customCell.subtitleLabel.isHidden = false
//        customCell.incomeSubtitleLabel?.isHidden = false
//
//        if cell.dateIsToday {
//            customCell.customSelectionView.isHidden = true
//            customCell.selectionLayer.isHidden = false
//            customCell.titleLabel.textColor = MTColors.mainText
//        } else {
//            customCell.selectionLayer.isHidden = true
//        }
//
//        let sum = transactionsDataSource?.sumOfDate(date: date, account: [])
//        customCell.subtitleLabel?.text = sum?.0
//        customCell.incomeSubtitleLabel?.text = sum?.1
//    }
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
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
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
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCalendarCell else { return }
        calendar.visibleDates({ [unowned self] datesInfo in
            if datesInfo.monthDates.first?.date.month != date.month {
                self.calendar?.scrollToDate(date)
            } else {
                validCell.configureCell(cellState: cellState)
            }
        })
        delegate?.didSelect(date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCalendarCell else { return }
        validCell.configureCell(cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        delegate?.didScrollto(dateSegmentWith: visibleDates)
    }
}
