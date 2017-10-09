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
    
    var notifToken: NotificationToken?
    var diffCalculator: TableViewDiffCalculator<String, BillEntry>?
    var sortedEntries: SectionedValues<String, BillEntry>? {
        didSet {
            guard let entries = sortedEntries else { return }
            diffCalculator?.sectionedValues = entries
        }
    }
    
    var displayedSectionStack: [BillSections.RawValue] = []
    weak var delegate: (BillsDataSourceDelegate & SwipeTableViewCellDelegate)?
    
    deinit {
        notifToken?.stop()
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
        self.notifToken = self.billEntries?.addNotificationBlock({ [unowned self] (_) in
            self.sortEntries()
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
}

extension BillsDataSource: BillsCellDelegate {
    func didPressPayBill(entry: BillEntry) {
        delegate?.didPressPayBill(entry: entry)
    }
}

extension BillsDataSource: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillsCell") as? BillsCell else {
            fatalError("Cannot convert UITableViewCell to BillsCell")
        }
        guard let entry = diffCalculator?.value(atIndexPath: indexPath) else {
            fatalError("Invalid row index")
        }
        
        cell.setValue(of: entry, currency: currency!)
        cell.delegate = delegate
        cell.billsCellDelegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let entry = entry(at: indexPath) else { return }
        delegate?.didSelect(entry: entry)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.size.width, height: 20)))
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 10, y: 0), size: view.frame.size))
        view.addSubview(label)
        
        guard let headerStr = diffCalculator?.value(forSection: section) else {
             fatalError("Invalid section index")
        }

        if headerStr == BillSections.overdue.rawValue {
            view.backgroundColor = MTColors.subRed
        } else if headerStr == BillSections.sevenDays.rawValue {
            view.backgroundColor = MTColors.subBlue
        } else {
            view.backgroundColor = MTColors.lightBg
        }

        let attributes = [NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 12)]
        label.attributedText = NSAttributedString(string: headerStr, attributes: attributes)
        if !displayedSectionStack.contains(headerStr) { displayedSectionStack.insert(headerStr, at: section) }
        return view
    }
}
