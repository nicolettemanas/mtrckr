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
    func createBillbtnPressed(sender: UIBarButtonItem?)
    func deleteBillEntry(atIndex: IndexPath)
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
        let resolver = MTResolver()
        emptyDataSource = resolver.container.resolve(EmptyBillsDataSource.self)
        dataSource = resolver.container.resolve(BillsDataSource.self)
        dataSource?.delegate = self
        billVCPresenter = resolver.container.resolve(BillVCPresenter.self)
        deleteBillPresenter = resolver.container.resolve(DeleteBillPresenter.self)
        presenter = resolver.container.resolve(BillsPresenter.self)
    }
    
    static func initWith(dataSource: BillsDataSourceProtocol,
                         emptyDataSource: EmptyBillsDataSource?,
                         newBillPresenter: BillVCPresenterProtocol,
                         deleteBillPresenter: DeleteBillPresenterProtocol,
                         presenter: BillsPresenterProtocol)
        -> BillsTableViewController {
            
        let storyboard = UIStoryboard(name: "Bills", bundle: Bundle.main)
        guard let vc: BillsTableViewController = storyboard.instantiateViewController(withIdentifier: "BillsTableViewController")
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
