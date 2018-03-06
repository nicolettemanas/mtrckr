//
//  BillHistoryDataSource.swift
//  mtrckr
//
//  Created by User on 10/23/17.
//

import UIKit
import RealmSwift
import SwipeCellKit

protocol BillHistoryDataSourceProtocol: UITableViewDelegate, UITableViewDataSource {
    var history: Results<BillEntry>? { get }
    var cellDelegate: (SwipeTableViewCellDelegate & BillHistoryDataSourceDelegate)? { get set }
    func refreshHistory()
}

protocol BillHistoryDataSourceDelegate: class {
    func didUpdate(changes: RealmCollectionChange<Results<BillEntry>>)
    func toggleFooter(show: Bool)
}

class BillHistoryDataSource: RealmHolder, BillHistoryDataSourceProtocol {
    static let historyLbl = NSLocalizedString("history.label",
                                              tableName: nil,
                                              bundle: Bundle.main,
                                              value: "Payment History",
                                              comment: "Title of the label showing the payment history of a bill")
    private var bill: Bill
    private var notifToken: NotificationToken?
    private(set) var history: Results<BillEntry>?
    weak var cellDelegate: (SwipeTableViewCellDelegate & BillHistoryDataSourceDelegate)?

    init(bill billSource: Bill) {
        bill = billSource
        super.init(with: RealmAuthConfig())
    }

    func refreshHistory() {
        assert(cellDelegate != nil)
        history = bill.history(in: realmContainer!.userRealm!)
        notifToken = history?.observe({ [weak self] (changes) in
            if let strongSelf = self {
                strongSelf.cellDelegate?.didUpdate(changes: changes)
                strongSelf.cellDelegate?.toggleFooter(show: strongSelf.history?.count ?? 0 == 0)
            }
        })
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        let view = UIView(
            frame: CGRect(origin: CGPoint.zero,
                          size: CGSize(
                            width: tableView.frame.size.width,
                            height: 20)))

        let label = UILabel(
            frame: CGRect(
                origin: CGPoint(x: 10, y: 0),
                size: view.frame.size))

        view.addSubview(label)
        view.backgroundColor = MTColors.lightBg
        let attributes = [NSAttributedStringKey.font: UIFont.italicSystemFont(ofSize: 12)]
        label.attributedText =
            NSAttributedString(string: BillHistoryDataSource.historyLbl,
                               attributes: attributes)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 20
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return history?.count ?? 0 }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillHistoryCell") as? BillsHistoryCell
            else { fatalError("Cannot cast to type BillHistoryCell") }
        guard let his = history
            else { fatalError("No history found") }
        guard indexPath.row < his.count
            else { fatalError("Invalid index") }

        let row = his[indexPath.row]
        cell.setValue(entry: row, currency: realmContainer!.currency())
        cell.delegate = cellDelegate
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
