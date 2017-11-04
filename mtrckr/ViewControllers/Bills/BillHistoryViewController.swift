//
//  BillHistoryViewController.swift
//  mtrckr
//
//  Created by User on 10/23/17.
//

import UIKit
import RealmSwift

class BillHistoryViewController: MTTableViewController {

    static let nName = "BillHistoryViewController"
    
    var bill: Bill?
    var dataSource: BillHistoryDataSourceProtocol?
    var presenter: BillsPresenterProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(bill != nil)
        assert(dataSource != nil)
    }
    
    init(bill billSource: Bill,
         dataSource historyDataSource: BillHistoryDataSourceProtocol,
         presenter billsPresenter: BillsPresenterProtocol) {
        
        bill = billSource
        dataSource = historyDataSource
        presenter = billsPresenter
        super.init(nibName: BillHistoryViewController.nName, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bill History"
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        registerNibs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildHeader()
        dataSource?.refreshHistory()
    }
    
    @objc func unpay(indexPath: IndexPath) {
        guard let entry = dataSource?.history![indexPath.row]
            else { return }
        presenter?.unpay(entry: entry)
    }
    
    func entry(forIndexPath indexPath: IndexPath) -> BillEntry? {
        guard let hist = dataSource?.history else { return nil }
        return hist[indexPath.row]
    }
    
    private func registerNibs() {
        tableView.register(UINib(nibName: "BillHistoryCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "BillHistoryCell")
    }
    
    private func buildHeader() {
        guard let cell = Bundle.main.loadNibNamed("BillHeaderView", owner: nil, options: nil)?.first
            as? BillHeaderView else { fatalError("Cannot find BillHeaderView") }
        guard let realmHolder = dataSource as? RealmHolder else { return }
        cell.setValue(bill: bill!, currency: realmHolder.realmContainer!.currency())
        tableView.tableHeaderView = cell
    }
}

extension BillHistoryViewController: BillHistoryDataSourceDelegate {
    func didUpdate(changes: RealmCollectionChange<Results<BillEntry>>) {
        tableView.applyChanges(forSection: 1, changes: changes, inserting: false)
    }
    
    func toggleFooter(show: Bool) {
        if show == true {
            guard let cell = Bundle.main.loadNibNamed("BillFooterView", owner: nil, options: nil)?.first
                as? BillFooterView else { fatalError("Cannot find BillFooterView") }
            tableView.tableFooterView = cell
        } else { tableView.tableFooterView = nil }
    }
}
