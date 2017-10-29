//
//  BillHistoryViewController.swift
//  mtrckr
//
//  Created by User on 10/23/17.
//

import UIKit

class BillHistoryViewController: MTTableViewController {

    static let nName = "BillHistoryViewController"
    
    var bill: Bill?
    var dataSource: BillHistoryDataSourceProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("coder")
        assert(bill != nil)
        assert(dataSource != nil)
    }
    
    init(bill billSource: Bill, dataSource historyDataSource: BillHistoryDataSourceProtocol) {
        bill = billSource
        dataSource = historyDataSource
        super.init(nibName: BillHistoryViewController.nName, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bill History"
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.register(UINib(nibName: "BillHistoryCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "BillHistoryCell")
        tableView.register(UINib(nibName: "BillsCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "BillsCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillsCell") as? BillsCell
            else { fatalError("Cannot cast to type BillsCell") }
        guard let realmHolder = dataSource as? RealmHolder else { return }
        cell.setValue(bill: bill!, currency: realmHolder.realmContainer!.currency())
        cell.backgroundColor = .white
        tableView.tableHeaderView = cell
    }
}
