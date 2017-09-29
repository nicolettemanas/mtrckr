//
//  BillsTableViewController.swift
//  mtrckr
//
//  Created by User on 8/15/17.
//

import UIKit
import RealmSwift

enum ModifyBillType: String {
    case allBills, currentBill
}

protocol BillsTableViewControllerProtocol {
    var dataSource: BillsDataSourceProtocol? { get set }
    
    func editBillEntry(atIndex: IndexPath)
    func createBillbtnPressed(sender: UIBarButtonItem?)
    func deleteBillEntry(atIndex: IndexPath)
}

class BillsTableViewController: MTTableViewController, BillsTableViewControllerProtocol, NewBillViewControllerDelegate {
    
    var dataSource: BillsDataSourceProtocol?
    var emptyDataSource: EmptyBillsDataSource?
    var newBillPresenter: NewBillPresenterProtocol?
    var deleteBillPresenter: DeleteBillPresenterProtocol?
    var presenter: BillsPresenterProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let resolver = ViewControllerResolvers()
        emptyDataSource = resolver.container.resolve(EmptyBillsDataSource.self)
        dataSource = resolver.container.resolve(BillsDataSource.self)
        dataSource?.delegate = self
        newBillPresenter = resolver.container.resolve(NewBillPresenter.self)
        deleteBillPresenter = resolver.container.resolve(DeleteBillPresenter.self)
        presenter = resolver.container.resolve(BillsPresenter.self)
    }
    
    static func initWith(dataSource: BillsDataSourceProtocol,
                         emptyDataSource: EmptyBillsDataSource?,
                         newBillPresenter: NewBillPresenterProtocol,
                         deleteBillPresenter: DeleteBillPresenterProtocol,
                         presenter: BillsPresenterProtocol)
        -> BillsTableViewController {
            
        let storyboard = UIStoryboard(name: "Bills", bundle: Bundle.main)
        guard let vc: BillsTableViewController = storyboard.instantiateViewController(withIdentifier: "BillsTableViewController")
            as? BillsTableViewController else { fatalError("Cannot convert to BillsTableViewController") }
        vc.dataSource = dataSource
        vc.dataSource?.delegate = vc
        vc.emptyDataSource = emptyDataSource
        vc.newBillPresenter = newBillPresenter
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
        dataSource?.refresh()
    }
    
    // MARK: - Bill modification
    @IBAction func createBillbtnPressed(sender: UIBarButtonItem?) {
        self.newBillPresenter?.presentNewBill(presenter: self, billEntry: nil)
    }
    
    func editBillEntry(atIndex index: IndexPath) {
        self.newBillPresenter?.presentNewBill(presenter: self, billEntry: dataSource?.entry(at: index))
    }
    
    func deleteBillEntry(atIndex index: IndexPath) {
        guard let entry = dataSource?.entry(at: index) else { return }
        self.deleteBillPresenter?.presentDeleteSheet(presentingVC: self, forBillEntry: entry)
    }
    
    // MARK: NewBillViewControllerDelegate
    func saveNewBill(amount: Double, name: String, post: String, pre: String,
                     repeatSchedule: String, startDate: Date, category: Category) {
        presenter?.createBill(amount: amount, name: name, post: post, pre: pre, repeatSchedule: repeatSchedule,
                              startDate: startDate, category: category)
    }
    
    func edit(billEntry: BillEntry, amount: Double, name: String, post: String,
              pre: String, repeatSchedule: String, startDate: Date, category: Category) {
        presenter?.editBillEntry(billEntry: billEntry, amount: amount, name: name,
                                 post: post, pre: pre, startDate: startDate, category: category)
    }
    
    func edit(bill: Bill, amount: Double, name: String, post: String, pre: String,
              repeatSchedule: String, startDate: Date, category: Category, proceedingDate: Date) {
        presenter?.editBillAndEntries(bill: bill, amount: amount, name: name, post: post, pre: pre,
                                      repeatSchedule: repeatSchedule, startDate: startDate, category: category,
                                      proceedingDate: proceedingDate)
    }
}

extension BillsTableViewController: BillsDataSourceDelegate {
    func didUpdateBills(withChanges changes: RealmCollectionChange<Results<Bill>>) {
        print("UPDATED: Bills")
    }
    
    func didSelect(entry: BillEntry) {
        presenter?.showHistory(of: entry)
    }
    
    func didPressPayBill(entry: BillEntry) {
        presenter?.payEntry(entry: entry)
    }
    
    func didUpdateOverdues(withChanges changes: RealmCollectionChange<Results<BillEntry>>, inserting: Bool) {
        print("UPDATED: Overdue BillEntries")
        guard let index = dataSource?.index(ofSection: BillSections.overdue.rawValue) else { return }
        tableView.applyChanges(forSection: index, changes: changes, inserting: inserting)
    }
    
    func didUpdateSevenDays(withChanges changes: RealmCollectionChange<Results<BillEntry>>, inserting: Bool) {
        print("UPDATED: 7 Days BillEntries")
        guard let index = dataSource?.index(ofSection: BillSections.sevenDays.rawValue) else { return }
        tableView.applyChanges(forSection: index, changes: changes, inserting: inserting)
    }
    
    func didUpdateThirtyDays(withChanges changes: RealmCollectionChange<Results<BillEntry>>, inserting: Bool) {
        print("UPDATED: 30 Days BillEntries")
        guard let index = dataSource?.index(ofSection: BillSections.thirtyDays.rawValue) else { return }
        tableView.applyChanges(forSection: index, changes: changes, inserting: inserting)
    }
}

extension BillsTableViewController: DeleteBillPresenterDelegate {
    func proceedDeleteEntry(entry: BillEntry, type: ModifyBillType) {
        presenter?.deleteBillEntry(entry: entry, deleteType: type)
    }
    
    func cancelDeleteEntry(entry: BillEntry) {
        
    }
}

extension BillsTableViewController: NewBillPresenterDelegate {
    func proceedEditEntry(atIndex indexPath: IndexPath) {
        
    }
    
    func proceedEditProceedingEntries(ofBillAtIndexPath index: IndexPath, fromDate date: Date) {
        
    }
}
