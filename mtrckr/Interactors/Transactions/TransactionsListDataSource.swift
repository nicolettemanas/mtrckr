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

enum TransactionsFilter {
    case byAccount, byDate
}

protocol TransactionsListDataSourceDelegate: class {
    func didUpdateTransactions()
}

protocol TransactionsListDataSourceProtocol: UITableViewDelegate, UITableViewDataSource {
    init(authConfig: AuthConfig, parentVC pVC: TransactionsTableViewControllerProtocol?, tableView: UITableView, filterBy filter: TransactionsFilter)
    var filterBy: TransactionsFilter { get set }
    var accountsFilter: [Account] { get set }
    var dateFilter: Date { get set }
    var delegate: TransactionsListDataSourceDelegate? { get set }
    
    func reloadByDate(with date: Date)
    func reloadByAccounts(with accounts: [Account])
    func sumOfDate(date: Date, account: [Account]) -> (String, String)
}

class TransactionsListDataSource: RealmHolder, TransactionsListDataSourceProtocol {
    
    var accountsFilter: [Account] = []
    var dateFilter: Date = Date()
    
    private weak var parentVC: TransactionsTableViewControllerProtocol?
    weak var transactionsTable: UITableView?
    weak var delegate: TransactionsListDataSourceDelegate?
    
    var transactions: Results<Transaction>?
    var currency: String = ""
    var monthSections: [(Date, Date)] = []
    var sectionTitles: [String] = []
    var notifToken: NotificationToken?
    var filterBy: TransactionsFilter
    
    // MARK: - Initializers
    required init(authConfig: AuthConfig,
                  parentVC pVC: TransactionsTableViewControllerProtocol?,
                  tableView: UITableView, filterBy filter: TransactionsFilter) {
        
        filterBy = filter
        dateFilter = Date()
        accountsFilter = []
        
        super.init(with: authConfig)
        
        parentVC = pVC
        transactionsTable = tableView
        
        if filterBy == .byDate {
            dateFilter = Date()
        } else {
            accountsFilter = Array(Account.all(in: realmContainer!.userRealm!))
        }
        
        currency = realmContainer!.currency()
        setupTransactions()
    }
    
    // MARK: - TransactionsListDataSourceProtocol methods
    func reloadByDate(with date: Date) {
        filterBy = .byDate
        dateFilter = date
        setupTransactions()
    }
    
    func reloadByAccounts(with accounts: [Account]) {
        filterBy = .byAccount
        accountsFilter = accounts
        setupTransactions()
    }
    
    func sumOfDate(date: Date, account: [Account]) -> (String, String) {
        if account.count == 0 {
            let trns = Transaction.all(in: realmContainer!.userRealm!, onDate: date)
            let transSum = sum(of: trns)
            return (transSum.0 > 0 ? (NumberFormatter.currencyKString(withCurrency: currency, amount: transSum.0) ?? "") : "",
                    transSum.1 > 0 ? (NumberFormatter.currencyKString(withCurrency: currency, amount: transSum.1) ?? "") : "")
        }
        return ("", "")
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate methods
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filterBy == .byDate {
            return nil
        }
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterBy == .byDate {
            return transactions?.count ?? 0
        }
        
        return rowsForSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if filterBy == .byDate {
            return 10
        }
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if filterBy == .byDate {
            return 1
        }
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as? TransactionTableViewCell else {
            fatalError("Cannot initialize TransactionTableViewCell")
        }
        
        let t = transactions![indexPath.row]
        cell.setValues(ofTransaction: t, withCurrency: currency)
        cell.delegate = parentVC as? SwipeTableViewCellDelegate
        return cell
    }
    
    // MARK: - Other methods
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
                    self.transactions = Transaction.all(in: self.realmContainer!.userRealm!, fromAccount: self.accountsFilter[0])
                    self.sectionTitles = self.generateTitles()
                case .byDate:
                    self.transactions = Transaction.all(in: self.realmContainer!.userRealm!, onDate: self.dateFilter)
            }
            
            self.notifToken = self.transactions?.addNotificationBlock({ (change) in
                self.transactionsTable!.applyChanges(changes: change)
                self.delegate?.didUpdateTransactions()
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
