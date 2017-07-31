//
//  TransactionsListDataSource.swift
//  mtrckr
//
//  Created by User on 7/7/17.
//

import UIKit
import Realm
import RealmSwift
import SwipeCellKit
import DateToolsSwift

/// Filter types for presenting a list of `Transactions` in `TransactionsTableViewController`
///
/// - `.byAccount`: Transaction type when `Transactions` should be filtered by `Accounts`
/// - `.byDate`: Transaction type when `Transactions` should be filtered by Date
enum TransactionsFilter {
    case byAccount, byDate
}

protocol TransactionsListDataSourceDelegate: class {
    func didUpdateTransactions()
    func didReceiveChanges(changes: RealmCollectionChange<Results<Transaction>>)
}

protocol TransactionsListDataSourceProtocol: UITableViewDelegate, UITableViewDataSource {
    init(authConfig: AuthConfig,
         delegate del: TransactionsListDataSourceDelegate?,
         filterBy filter: TransactionsFilter,
         date: Date?,
         accounts: [Account])
    var filterBy: TransactionsFilter { get set }
    var accountsFilter: [Account] { get set }
    var dateFilter: Date? { get set }
    var delegate: TransactionsListDataSourceDelegate? { get set }
    
    func reloadByDate(with date: Date)
    func reloadByAccounts(with accounts: [Account])
    func sumOfDate(date: Date, account: [Account]) -> (String, String)
    func transaction(at indexPath: IndexPath) -> Transaction?
}

/// The datasource of `TransactionsTableViewController`
class TransactionsListDataSource: RealmHolder, TransactionsListDataSourceProtocol {
    
    /// Array of `Accounts` as filter
    var accountsFilter: [Account] = []
    
    /// Date as filter
    var dateFilter: Date?
    
    private var notifToken: NotificationToken?
    private var monthSections: [(Date, Date)] = []
    private var transactions: Results<Transaction>?
    
    weak var delegate: TransactionsListDataSourceDelegate?
    
    var currency: String = ""
    var sectionTitles: [String] = []
    
    /// Type of Transaction filter
    var filterBy: TransactionsFilter {
        didSet {
            setupTransactions()
        }
    }
    
    deinit {
            notifToken?.stop()
    }
    
    required init(authConfig: AuthConfig,
                  delegate del: TransactionsListDataSourceDelegate?,
                  filterBy filter: TransactionsFilter,
                  date: Date?,
                  accounts: [Account]) {
        
        filterBy = filter
        dateFilter = Date()
        accountsFilter = []
        dateFilter = date
        accountsFilter = accounts
        
        super.init(with: authConfig)
        
        delegate = del

        if filterBy == .byAccount && accountsFilter.count == 0 {
            accountsFilter = Array(Account.all(in: realmContainer!.userRealm!))
        } else if filterBy == .byDate && dateFilter == nil {
            dateFilter = Date()
        }
        
        currency = realmContainer!.currency()
        setupTransactions()
    }
    
    
    /// Reload the datasource by date
    ///
    /// - Parameter date: Date filter
    func reloadByDate(with date: Date) {
        filterBy = .byDate
        dateFilter = date
        setupTransactions()
    }
    
    /// Reload the datasource by `Accounts`
    ///
    /// - Parameter accounts: `Accounts` filter
    func reloadByAccounts(with accounts: [Account]) {
        filterBy = .byAccount
        accountsFilter = accounts
        setupTransactions()
    }
    
    /// :nodoc:
    func sumOfDate(date: Date, account: [Account]) -> (String, String) {
        if account.count == 0 {
            let trns = Transaction.all(in: realmContainer!.userRealm!, onDate: date)
            let transSum = sum(of: trns)
            return (transSum.0 > 0 ? (NumberFormatter.currencyKString(withCurrency: currency, amount: transSum.0) ?? "") : "",
                    transSum.1 > 0 ? (NumberFormatter.currencyKString(withCurrency: currency, amount: transSum.1) ?? "") : "")
        }
        return ("", "")
    }
    
    /// :nodoc:
    func transaction(at indexPath: IndexPath) -> Transaction? {
        return transactions?[indexPath.row] ?? nil
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filterBy == .byDate {
            return nil
        }
        return sectionTitles[section]
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterBy == .byDate {
            return transactions?.count ?? 0
        }
        
        return rowsForSection(section: section)
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if filterBy == .byDate {
            return 0
        }
        return 30
    }
    
    /// :nodoc:
    func numberOfSections(in tableView: UITableView) -> Int {
        if filterBy == .byDate {
            return 1
        }
        return sectionTitles.count
    }
    
    /// :nodoc:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as? TransactionTableViewCell else {
            fatalError("Cannot initialize TransactionTableViewCell")
        }
        
        let t = transactions![indexPath.row]
        cell.setValues(ofTransaction: t, withCurrency: currency)
        cell.delegate = delegate as? SwipeTableViewCellDelegate
        return cell
    }
    
    
    private func sum(of transactions: Results<Transaction>) -> (Double, Double) {
        var expenses: Double = 0
        var income: Double = 0
        for trans in transactions {
            if trans.type == TransactionType.expense.rawValue {
                expenses += trans.amount
            } else if trans.type == TransactionType.income.rawValue {
                income += trans.amount
            }
        }
        return (expenses, income)
    }
    
    private func setupTransactions() {
        DispatchQueue.main.async {
            switch self.filterBy {
                case .byAccount:
                    self.transactions = Transaction.all(in: self.realmContainer!.userRealm!, fromAccounts: self.accountsFilter)
                    self.sectionTitles = self.generateTitles()
                case .byDate:
                    self.transactions = Transaction.all(in: self.realmContainer!.userRealm!, onDate: self.dateFilter!)
            }
            
            self.notifToken?.stop()
            self.notifToken = self.transactions?.addNotificationBlock({ [weak self] change in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.didReceiveChanges(changes: change)
                strongSelf.delegate?.didUpdateTransactions()
            })
        }
    }
    
    private func rowsForSection(section: Int) -> Int {
        let sDate = monthSections[section].0
        let eDate = monthSections[section].1
        let trans = transactions?.filter("transactionDate >= %@ AND transactionDate <= %@", sDate, eDate)
        return trans?.count ?? 0
    }
    
    private func generateTitles() -> [String] {
        var titles: [String] = []
        if var minDate: Date = transactions?.min(ofProperty: "transactionDate") {
            minDate = minDate.start(of: .month)
            let maxDate = Date()
            
            var startDate = maxDate.start(of: .month)
            var endDate = maxDate.end(of: .month)
            
            while minDate.isEarlierThanOrEqual(to: startDate) {
                monthSections.append((startDate, endDate))
                
                let month = startDate.format(with: "MMM", timeZone: TimeZone.current)
                titles.append("\(month) \(startDate.year)")
                
                startDate = startDate.subtract(TimeChunk(seconds: 0, minutes: 0, hours: 0,
                                                  days: 0, weeks: 0, months: 1, years: 0))
                endDate = startDate.end(of: .month)
            }
        }
        return titles
    }
}
