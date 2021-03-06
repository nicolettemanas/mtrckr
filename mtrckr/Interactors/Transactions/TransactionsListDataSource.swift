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
    case byAccount, byDate, both
}

protocol TransactionsListDataSourceDelegate: class {
    func didUpdateTransactions()
    func didReceiveChanges(changes: RealmCollectionChange<Results<Transaction>>)
}

protocol TransactionsListDataSourceProtocol: UITableViewDelegate, UITableViewDataSource {
    init(authConfig: AuthConfig,
         filterBy filter: TransactionsFilter,
         date: Date?,
         accounts: [Account])
    var filterBy: TransactionsFilter { get set }
    var accountsFilter: [Account] { get set }
    var dateFilter: Date? { get set }
    var delegate: TransactionsListDataSourceDelegate? { get set }
    var transactions: Results<Transaction>? { get set }

    func reloadByDate(with date: Date)
    func reloadByAccounts(with accounts: [Account])
    func reloadBy(accounts: [Account], date: Date)
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

    // TODO: Implement Dwifft?
    /// `Transactions` displayed
    var transactions: Results<Transaction>?

    /// :nodoc:
    var groupedTransactions: [String: Results<Transaction>?] = [:]

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
        notifToken?.invalidate()
    }

    required init(authConfig: AuthConfig,
                  filterBy filter: TransactionsFilter,
                  date: Date?,
                  accounts: [Account]) {

        filterBy = filter
        dateFilter = Date()
        accountsFilter = []
        dateFilter = date
        accountsFilter = accounts

        super.init(with: authConfig)

        if filterBy == .byAccount && accountsFilter.count == 0 {
            accountsFilter = Array(Account.all(in: realmContainer!.userRealm!))
        } else if filterBy == .byDate && dateFilter == nil {
            dateFilter = Date()
        } else {
            accountsFilter = Array(Account.all(in: realmContainer!.userRealm!))
            dateFilter = Date()
        }

        currency = realmContainer!.currency()
        setupTransactions()
    }

    /// Reload the datasource by date
    ///
    /// - Parameter date: Date filter
    func reloadByDate(with date: Date) {
        dateFilter = date
        filterBy = .byDate
    }

    /// Reload the datasource by `Accounts`
    ///
    /// - Parameter accounts: `Accounts` filter
    func reloadByAccounts(with accounts: [Account]) {
        accountsFilter = accounts
        filterBy = .byAccount
    }

    /// Reload the datasource by `Accounts` and by date
    ///
    /// - Parameters:
    ///   - accounts: `Accounts` filter
    ///   - date: Date filter
    func reloadBy(accounts: [Account], date: Date) {
        accountsFilter = accounts
        dateFilter = date
        filterBy = .both
    }

    /// :nodoc:
    func transaction(at indexPath: IndexPath) -> Transaction? {
        return transactions?[indexPath.row] ?? nil
    }

    func getHeader(accounts: [Account]) -> String? {
        if isFilteringAllAccounts() == true { return nil }
        var header = "Filter: \(accounts.first!.name)"
        for account in accounts.dropFirst() {
            header = "\(header), \(account.name)"
        }
        return header
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
        switch self.filterBy {
        case .byAccount:
            self.transactions = Transaction.all(in: self.realmContainer!.userRealm!,
                                                fromAccounts: self.accountsFilter)
            self.sectionTitles = self.generateTitles()
            self.groupTransactions()
        case .byDate:
            self.transactions = Transaction.all(in: self.realmContainer!.userRealm!,
                                                onDate: self.dateFilter!)
        case .both:
            self.transactions = Transaction.all(in: self.realmContainer!.userRealm!,
                                                between: self.dateFilter!.start(of: .day),
                                                and: self.dateFilter!.end(of: .day),
                                                inAccounts: self.accountsFilter)
        }

        self.notifToken?.invalidate()
        self.notifToken = self.transactions?.observe({ [weak self] change in
            if let strongSelf = self {
                if strongSelf.filterBy == TransactionsFilter.byAccount {
                    strongSelf.delegate?.didUpdateTransactions()
                } else {
                    strongSelf.delegate?.didReceiveChanges(changes: change)
                }
            }
        })
    }

    private func groupTransactions() {
        for i in 0..<sectionTitles.count {
            if monthSections.count < 1 { return }

            let sDate = monthSections[i].0
            let eDate = monthSections[i].1
            let trans = transactions?.filter("transactionDate >= %@ AND transactionDate <= %@", sDate, eDate)
            groupedTransactions[monthSections[i].0.format(with: "MMM")] = trans
        }
    }

    func rowsCountSection(section: Int) -> Int {
        let monthIndex = monthSections[section].0.format(with: "MMM")
        return groupedTransactions[monthIndex]??.count ?? 0
    }

    func rowsForSection(section: Int) -> Results<Transaction>? {
        let monthIndex = monthSections[section].0.format(with: "MMM")
        return groupedTransactions[monthIndex]!
    }

    private func generateTitles() -> [String] {
        var titles: [String] = []
        if var minDate: Date = transactions?.min(ofProperty: "transactionDate") {
            minDate = minDate.start(of: .month)
            let maxDate: Date = transactions?.max(ofProperty: "transactionDate") ?? Date()

            var startDate = maxDate.start(of: .month)
            var endDate = maxDate.end(of: .month)

            while minDate.isEarlierThanOrEqual(to: startDate) {
                if monthSections.contains(where: { (arg) -> Bool in
                    return arg.0 == startDate && arg.1 == endDate
                }) == false {
                    monthSections.append((startDate, endDate))
                }

                let month = startDate.format(with: "MMM", timeZone: TimeZone.current)
                titles.append("\(month) \(startDate.year)")

                startDate = startDate.subtract(1.months)
                endDate = startDate.end(of: .month)
            }
        }
        return titles
    }

    func isFilteringAllAccounts() -> Bool {
        if accountsFilter.count == 0 ||
            accountsFilter.count == Account.all(in:
                self.realmContainer!.userRealm!).count {
            return true
        }
        return false
    }
}
