//
//  BillsTableViewController.swift
//  mtrckr
//
//  Created by User on 8/15/17.
//

import UIKit
import RealmSwift
import DZNEmptyDataSet

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

class EmptyBillsDataSource: NSObject, DZNEmptyDataSetSource {
    
    struct LocalizableStrings {
        static let emptyBillsTitle = NSLocalizedString("There are currently no saved bills.",
                   comment: "The title shown when there are no bills registered.")
        static let emptyBillsBody = NSLocalizedString("Tap the '+' button to add one.",
                  comment: "The description shown when there are no bills registered. Instructs user how to add a bill.")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return MTColors.emptyDataSetBg
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = LocalizableStrings.emptyBillsTitle
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        let attr = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
                    NSForegroundColorAttributeName: MTColors.placeholderText,
                    NSParagraphStyleAttributeName: style]
        return NSAttributedString(string: str, attributes: attr)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = LocalizableStrings.emptyBillsBody
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        style.alignment = .center
        let attr = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                    NSForegroundColorAttributeName: MTColors.placeholderText,
                    NSParagraphStyleAttributeName: style]
        return NSAttributedString(string: str, attributes: attr)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "atype-cash")
    }
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return MTColors.placeholderText
    }
}
