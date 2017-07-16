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

protocol TransactionsListDataSourceProtocol {
    init(authConfig: AuthConfig, parentVC pVC: TransactionsTableViewControllerProtocol?, tableView: UITableView, filterBy filter: TransactionsFilter)
    var filterBy: TransactionsFilter { get set }
    var accountsFilter: [Account] { get set }
    var dateFilter: Date { get set }
}

class TransactionsListDataSource: RealmHolder, TransactionsListDataSourceProtocol, UITableViewDelegate, UITableViewDataSource {
    var accountsFilter: [Account] = []
    var dateFilter: Date = Date()
    
    private weak var parentVC: TransactionsTableViewControllerProtocol?
    weak var transactionsTable: UITableView?
    
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
            return 0
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
        cell.selectionStyle = .none
        cell.delegate = parentVC as? SwipeTableViewCellDelegate
        return cell
    }
    
    // MARK: - Other methods
    
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
            })
            self.transactionsTable!.reloadData()
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
                
                startDate = startDate.subtract(TimeChunk(seconds: 0,
                                                  minutes: 0,
                                                  hours: 0,
                                                  days: 0,
                                                  weeks: 0,
                                                  months: 1,
                                                  years: 0))
                endDate = startDate.end(of: .month)
            }
        }
        return titles
    }
}