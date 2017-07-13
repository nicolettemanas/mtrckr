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

protocol TransactionsListDataSourceProtocol {
    init(parentVC: TransactionsTableViewControllerProtocol?)
}

class TransactionsListDataSource: NSObject, TransactionsListDataSourceProtocol, UITableViewDelegate, UITableViewDataSource {
    private weak var parentVC: TransactionsTableViewControllerProtocol?
    var transactions: Results<Transaction>?
    var currency: String = ""
    var monthSections: [(Date, Date)] = []
    var sectionTitles: [String] = []
    
    // MARK: - Initializers
    required init(parentVC pVC: TransactionsTableViewControllerProtocol?) {
        super.init()
        parentVC = pVC
        sectionTitles = generateTitles()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsForSection(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
    
    private func rowsForSection(section: Int) -> Int {
        let sDate = monthSections[section].0
        let eDate = monthSections[section].1
        let trans = transactions?.filter("transactionDate >= \(sDate) AND transactionDate <= \(eDate)")
        return trans?.count ?? 0
    }
    
    private func generateTitles() -> [String] {
        var titles: [String] = []
        if let minDate: Date = transactions?.min(ofProperty: "transactionDate") {
            let maxDate = Date()
            
            var startDate = maxDate.start(of: .month)
            var endDate = maxDate.end(of: .month)
            
            while minDate.isEarlier(than: startDate) {
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
