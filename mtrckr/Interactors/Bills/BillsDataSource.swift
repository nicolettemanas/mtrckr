//
//  BillsDataSource.swift
//  mtrckr
//
//  Created by User on 8/15/17.
//

import UIKit
import RealmSwift

protocol BillsDataSourceDelegate: class {
    func didUpdateBills(withChanges changes: RealmCollectionChange<Results<Bill>>)
    func didSelect(entry: BillEntry)
    func didPressPayBill(entry: BillEntry)
    
    func didUpdateOverdues(withChanges changes: RealmCollectionChange<Results<BillEntry>>, inserting: Bool)
    func didUpdateSevenDays(withChanges changes: RealmCollectionChange<Results<BillEntry>>, inserting: Bool)
    func didUpdateThirtyDays(withChanges changes: RealmCollectionChange<Results<BillEntry>>, inserting: Bool)
}

protocol BillsDataSourceProtocol: UITableViewDelegate, UITableViewDataSource {
    var delegate: BillsDataSourceDelegate? { get set }
    
    func index(ofSection sectionHeader: String) -> Int?
    func entry(at indexPath: IndexPath) -> BillEntry?
    func refresh()
}

enum BillSections: String {
    case overdue = "Overdue"
    case sevenDays = "Due in the next 7 days"
    case thirtyDays = "Due in the next 30 days"
}

class BillsDataSource: RealmHolder, BillsDataSourceProtocol {
    
    var bills: Results<Bill>?
    var billEntries: Results<BillEntry>?
    var sortedEntries = [String: Results<BillEntry>?]()
    var tableView: UITableView?
    var currency: String?
    
    var overDue: Results<BillEntry>?
    var sevenDays: Results<BillEntry>?
    var thirtyDays: Results<BillEntry>?
    
    var notifToken: NotificationToken?
    var overDueToken: NotificationToken?
    var sevenDaysToken: NotificationToken?
    var thirtyDaysToken: NotificationToken?
    
    var displayedSectionStack: [BillSections.RawValue] = []
    weak var delegate: BillsDataSourceDelegate?
    
    override init(with config: AuthConfig) {
        super.init(with: config)
        currency = realmContainer?.currency() ?? "₱"
    }
    
    func refresh() {
        refreshBills()
        refreshBillEntries()
        sortEntries()
        setTokens()
    }
    
    func entry(at indexPath: IndexPath) -> BillEntry? {
        guard let key = sectionHeader(forIndex: indexPath.section) else { return nil }
        return self.sortedEntries[key]??[indexPath.row]
    }
    
    private func refreshBillEntries() {
        self.billEntries = BillEntry.allUnpaid(in: self.realmContainer!.userRealm!)
    }
    
    private func refreshBills() {
        self.bills = Bill.all(in: self.realmContainer!.userRealm!)
        self.notifToken = self.bills?.addNotificationBlock({ [unowned self] (changes) in
            self.delegate?.didUpdateBills(withChanges: changes)
        })
        
        guard self.bills != nil else { return }
    }
    
    private func sortEntries() {
        guard let entries = self.billEntries else { return }
        
        sortedEntries = [:]
        let today = Date()
        self.overDue = entries.filter("dueDate <= %@", today.start(of: .day))
        self.sevenDays = entries.filter("dueDate > %@ AND dueDate <= %@", today.start(of: .day), today.start(of: .day).add(7.days))
        self.thirtyDays = entries.filter("dueDate > %@ AND dueDate <= %@", today.start(of: .day).add(7.days), today.start(of: .day).add(31.days))
        
        if self.overDue!.count > 0 {
            sortedEntries[BillSections.overdue.rawValue] = overDue
        }
        if self.sevenDays!.count > 0 {
            sortedEntries[BillSections.sevenDays.rawValue] = sevenDays
        }
        if self.thirtyDays!.count > 0 {
            sortedEntries[BillSections.thirtyDays.rawValue] = thirtyDays
        }
    }
    
    private func setTokens() {
        self.overDueToken = self.overDue?.addNotificationBlock({ [unowned self] (changes) in
            self.refreshBillEntries()
            self.sortEntries()
            self.delegate?.didUpdateOverdues(withChanges: changes, inserting:
                !self.displayedSectionStack.contains(BillSections.overdue.rawValue))
        })
        
        sevenDaysToken = sevenDays?.addNotificationBlock({ [unowned self] (changes) in
            self.refreshBillEntries()
            self.sortEntries()
            self.delegate?.didUpdateSevenDays(withChanges: changes, inserting:
                !self.displayedSectionStack.contains(BillSections.sevenDays.rawValue))
        })
        
        thirtyDaysToken = thirtyDays?.addNotificationBlock({ [unowned self] (changes) in
            self.refreshBillEntries()
            self.sortEntries()
            self.delegate?.didUpdateThirtyDays(withChanges: changes, inserting:
                !self.displayedSectionStack.contains(BillSections.thirtyDays.rawValue))
        })
    }
    
    func index(ofSection sectionHeader: String) -> Int? {
        switch sectionHeader {
        case BillSections.overdue.rawValue:
            return sortedEntries[BillSections.overdue.rawValue] == nil ? nil : 0
        case BillSections.sevenDays.rawValue:
            if sortedEntries[BillSections.sevenDays.rawValue] != nil {
                return sortedEntries[BillSections.overdue.rawValue] == nil ? 0 : 1
            }
            return nil
        case BillSections.thirtyDays.rawValue:
            if sortedEntries[BillSections.thirtyDays.rawValue] != nil {
                if sortedEntries[BillSections.overdue.rawValue] != nil {
                    return sortedEntries[BillSections.sevenDays.rawValue] == nil ? 1 : 2
                } else {
                    return sortedEntries[BillSections.sevenDays.rawValue] == nil ? 0 : 1
                }
            }
            return nil
        default: fatalError("Section header does not exist")
        }
    }
    
    func sectionHeader(forIndex index: Int) -> String? {
        switch index {
        case 0:
            if sortedEntries[BillSections.overdue.rawValue] == nil {
                return sortedEntries[BillSections.sevenDays.rawValue] == nil ?
                    BillSections.thirtyDays.rawValue : BillSections.sevenDays.rawValue
            }
            return BillSections.overdue.rawValue
        case 1:
            return sortedEntries[BillSections.sevenDays.rawValue] == nil ?
                BillSections.thirtyDays.rawValue : BillSections.sevenDays.rawValue
        case 2:
            assert(sortedEntries[BillSections.thirtyDays.rawValue] != nil)
            return BillSections.thirtyDays.rawValue
        default: fatalError("Bills table can only have a maximum of three sections")
        }
    }
}

extension BillsDataSource: BillsCellDelegate {
    func didPressPayBill(entry: BillEntry) {
        delegate?.didPressPayBill(entry: entry)
    }
}

extension BillsDataSource: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let key = sectionHeader(forIndex: section) else { return 0 }
        return self.sortedEntries[key]??.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillsCell") as? BillsCell else {
            fatalError("Cannot convert UITableViewCell to BillsCell")
        }
        
        guard let sectionIndex = sectionHeader(forIndex: indexPath.section) else {
            fatalError("Invalid section index")
        }
        
        guard let entry = sortedEntries[sectionIndex]??[indexPath.row] else {
            fatalError("Invalid row index")
        }
        
        cell.setValue(of: entry, currency: currency!)
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedEntries.count
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
        guard let headerStr = sectionHeader(forIndex: section) else {
            fatalError("Invalid section index")
        }

        if headerStr == BillSections.overdue.rawValue {
            view.backgroundColor = MTColors.subRed
        } else if headerStr == BillSections.sevenDays.rawValue {
            view.backgroundColor = MTColors.subBlue
        } else {
            view.backgroundColor = MTColors.lightBg
        }

        let attributes = [NSFontAttributeName: UIFont.italicSystemFont(ofSize: 12)]
        label.attributedText = NSAttributedString(string: headerStr, attributes: attributes)
        if !displayedSectionStack.contains(headerStr) { displayedSectionStack.insert(headerStr, at: section) }
        return view
    }
}
