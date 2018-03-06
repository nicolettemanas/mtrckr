//
//  BillsTableViewController.swift
//  mtrckr
//
//  Created by User on 8/15/17.
//

import UIKit
import RealmSwift
import SwipeCellKit

enum ModifyBillType: String {
    case allBills, currentBill
}

protocol BillsTableViewControllerProtocol {
    var dataSource: BillsDataSourceProtocol? { get set }

    func editBillEntry(atIndex: IndexPath)
    func deleteBillEntry(atIndex: IndexPath)
    func skipBillEntry(atIndex: IndexPath)
    func createBillbtnPressed(sender: UIBarButtonItem?)
}

class BillsTableViewController: MTTableViewController {

    var dataSource: BillsDataSourceProtocol?
    var emptyDataSource: EmptyBillsDataSource?
    var billVCPresenter: BillVCPresenterProtocol?
    var deleteBillPresenter: DeleteBillPresenterProtocol?
    var presenter: BillsPresenterProtocol?
    weak var billsTableView: UITableView?

    var editingIndexPath: IndexPath?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        emptyDataSource = MTResolver.shared.bills.resolve(EmptyBillsDataSource.self)
        billVCPresenter = MTResolver.shared.bills.resolve(BillVCPresenter.self)
        deleteBillPresenter = MTResolver.shared.bills.resolve(DeleteBillPresenter.self)
        presenter = MTResolver.shared.bills.resolve(BillsPresenter.self)
        dataSource = MTResolver.shared.bills.resolve(BillsDataSource.self)
        dataSource?.delegate = self
    }

    static func initWith(dataSource: BillsDataSourceProtocol,
                         emptyDataSource: EmptyBillsDataSource?,
                         newBillPresenter: BillVCPresenterProtocol,
                         deleteBillPresenter: DeleteBillPresenterProtocol,
                         presenter: BillsPresenterProtocol)
        -> BillsTableViewController {

        let storyboard = UIStoryboard(name: "Bills", bundle: Bundle.main)
        guard let vc: BillsTableViewController = storyboard
            .instantiateViewController(withIdentifier: "BillsTableViewController")
            as? BillsTableViewController else { fatalError("Cannot convert to BillsTableViewController") }

        vc.dataSource = dataSource
        vc.dataSource?.delegate = vc
        vc.emptyDataSource = emptyDataSource
        vc.billVCPresenter = newBillPresenter
        vc.deleteBillPresenter = deleteBillPresenter
        vc.presenter = presenter
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.emptyDataSetSource = emptyDataSource
        tableView.register(UINib(nibName: "BillsCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "BillsCell")
        billsTableView = tableView
        dataSource?.refresh()
    }
}
