//
//  BillsDataSource.swift
//  mtrckr
//
//  Created by User on 8/15/17.
//

import UIKit
import RealmSwift
import SwipeCellKit
import Dwifft

protocol BillsDataSourceDelegate: class {
    func didUpdateBills(withChanges changes: RealmCollectionChange<Results<Bill>>)
    func didSelect(entry: BillEntry)
    func didPressPayBill(entry: BillEntry)
    weak var billsTableView: UITableView? { get set }
}

protocol BillsDataSourceProtocol: UITableViewDelegate, UITableViewDataSource {
    var delegate: (BillsDataSourceDelegate & SwipeTableViewCellDelegate)? { get set }
    func entry(at indexPath: IndexPath) -> BillEntry?
    func refresh()
}

class BillsDataSource: RealmHolder, BillsDataSourceProtocol {
    
    enum BillSections: String {
        case overdue = "Overdue"
        case sevenDays = "Due in the next 7 days"
        case thirtyDays = "Due in the next 30 days"
    }

    var billEntries: Results<BillEntry>?
    var currency: String?
    
    private var notifToken: NotificationToken?
    
    var diffCalculator: TableViewDiffCalculator<String, BillEntry>?
    var sortedEntries: SectionedValues<String, BillEntry>? {
        didSet {
            guard let entries = sortedEntries else { return }
            diffCalculator?.sectionedValues = entries
            relaodVisibleCells()
        }
    }
    
    var displayedSectionStack: [BillSections.RawValue] = []
    weak var delegate: (BillsDataSourceDelegate & SwipeTableViewCellDelegate)?
    
    deinit {
        notifToken?.invalidate()
    }
    
    override init(with config: AuthConfig) {
        super.init(with: config)
        currency = realmContainer?.currency() ?? "₱"
    }
    
    func refresh() {
        diffCalculator = TableViewDiffCalculator(tableView: delegate?.billsTableView,
                                                 initialSectionedValues: SectionedValues([(String, [BillEntry])]()))
        diffCalculator?.insertionAnimation = .fade
        diffCalculator?.deletionAnimation = .fade
        
        refreshBillEntries()
        sortEntries()
    }
    
    func entry(at indexPath: IndexPath) -> BillEntry? {
        return self.diffCalculator?.value(atIndexPath: indexPath)
    }
    
    private func refreshBillEntries() {
        self.billEntries = BillEntry.allUnpaid(in: self.realmContainer!.userRealm!)
        self.notifToken = self.billEntries?.observe({ [weak self] (_) in
            if let strongSelf = self {
                strongSelf.sortEntries()
            }
        })
    }
    
    private func sortEntries() {
        guard let entries = self.billEntries else { return }
        
        var mutable = [(String, [BillEntry])]()
        let today = Date()
        
        let overDue = entries.filter("dueDate <= %@", today.start(of: .day))
        let sevenDays = entries.filter("dueDate > %@ AND dueDate <= %@", today.start(of: .day), today.start(of: .day).add(7.days))
        let thirtyDays = entries.filter("dueDate > %@ AND dueDate <= %@", today.start(of: .day).add(7.days), today.start(of: .day).add(31.days))
        
        if overDue.count > 0 { mutable.append((BillSections.overdue.rawValue, Array(overDue))) }
        if sevenDays.count > 0 { mutable.append((BillSections.sevenDays.rawValue, Array(sevenDays))) }
        if thirtyDays.count > 0 { mutable.append((BillSections.thirtyDays.rawValue, Array(thirtyDays))) }
        
        self.sortedEntries = SectionedValues(mutable)
    }
    
    private func relaodVisibleCells() {
        delegate?.billsTableView?.visibleCells.forEach({ [unowned self] (cell) in
            guard let billCell = cell as? BillsCell else { return }
            guard let index = self.delegate?.billsTableView?.indexPath(for: billCell) else { return }
            guard let calculator = self.diffCalculator else { return }
            billCell.setValue(of: calculator.value(atIndexPath: index), currency: self.currency ?? "₱")
        })
    }
}

extension BillsDataSource: BillsCellDelegate {
    func didPressPayBill(entry: BillEntry) {
        delegate?.didPressPayBill(entry: entry)
    }
}
