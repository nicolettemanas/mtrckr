//
//  AccountsTableViewController.swift
//  mtrckr
//
//  Created by User on 6/27/17.
//

import UIKit
import SwipeCellKit
import Realm
import RealmSwift
import DZNEmptyDataSet

protocol AccountsTableViewControllerProtocol {
    var presenter: AccountsPresenterProtocol? { get set }
}

class AccountsTableViewController: MTTableViewController, AccountsTableViewControllerProtocol, UserObserver {
    
    // MARK: - Properties
    
    var accounts: Results<Account>?
    var currency: String?
    var notifToken: NotificationToken?
    var observer: ObserverProtocol?
    
    var presenter: AccountsPresenterProtocol?
    var emptyDatasource: EmptyAccountsDataSource?
    var transactionsDataSource: TransactionsListDataSourceProtocol?
    var newAccountPresenter: NewAccountPresenterProtocol?
    var deleteSheetPresenter: DeleteSheetPresenterProtocol?
    var transactionsPresenter: AccountTransactionsPresenterProtocol?
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    
    // MARK: - Static initializer for dependencies
    static func initWith(presenter: AccountsPresenterProtocol?,
                         emptyDataSource: EmptyAccountsDataSource?,
                         transactionsDataSource: TransactionsListDataSourceProtocol?,
                         newAccountPresenter: NewAccountPresenterProtocol?,
                         deleteSheetPresenter: DeleteSheetPresenterProtocol?,
                         transactionsPresenter: AccountTransactionsPresenterProtocol?)
        -> AccountsTableViewController {
            
        let storyboard = UIStoryboard(name: "Accounts", bundle: Bundle.main)
        guard let avc = storyboard.instantiateViewController(withIdentifier: "MTAccountsTableViewController")
            as? AccountsTableViewController else {
                fatalError("AccountsTableViewController does not conform to protocol AccountsTableViewControllerProtocol")
        }
            
        avc.presenter = presenter
        avc.emptyDatasource = emptyDataSource
        avc.transactionsDataSource = transactionsDataSource
        avc.newAccountPresenter = newAccountPresenter
        avc.deleteSheetPresenter = deleteSheetPresenter
        avc.transactionsPresenter = transactionsPresenter
        
        return avc
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let resolver = ViewControllerResolvers()
        self.presenter = resolver.container.resolve(AccountsPresenter.self)
        self.emptyDatasource = resolver.container.resolve(EmptyAccountsDataSource.self)
        self.newAccountPresenter = resolver.container.resolve(NewAccountPresenter.self)
        self.deleteSheetPresenter = resolver.container.resolve(DeleteSheetPresenter.self)
        self.transactionsPresenter = resolver.container.resolve(AccountTransactionsPresenter.self)
        self.transactionsDataSource = resolver.container.resolve(TransactionsListDataSource.self,
                                                                 arguments: TransactionsFilter.byAccount, [Account]())
    }
    
    // MARK: - Life cycle
    deinit {
        self.notifToken?.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "AccountTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "AccountTableViewCell")
        tableView.emptyDataSetSource = emptyDatasource
        tableView.emptyDataSetDelegate = emptyDatasource
        
        currency = presenter?.currency()
        setupResults()
        observer = NotificationObserver()
        observer?.setDidChangeUserBlock {
            self.setupResults()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBActions
    @IBAction func addAccountBtnPressed(_ sender: Any) {
        newAccountPresenter?.presentNewAccountVC(with: nil, presentingVC: self, delegate: self)
    }
    
    // MARK: - Accounts modification methods
    func editAccount(atIndex indexPath: IndexPath) {
        newAccountPresenter?.presentNewAccountVC(with: accounts![indexPath.row], presentingVC: self, delegate: self)
    }
    
    func confirmDelete(atIndex indexPath: IndexPath) {
        deleteSheetPresenter?.displayDeleteSheet(toDelete: indexPath, presentingVC: self)
    }
    
    func deleteAccount(atIndex indexPath: IndexPath) {
        presenter?.deleteAccount(account: accounts![indexPath.row])
    }
    
    func setupResults() {
        self.accounts = self.presenter?.accounts()
        DispatchQueue.main.async {
            self.notifToken = self.accounts?.addNotificationBlock(self.tableView.applyChanges)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source & delegate methods
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell") as? AccountTableViewCell else {
            fatalError("Cannot initialize AccountTableViewCell")
        }
        
        let a = accounts![indexPath.row]
        cell.setValues(ofAccount: a, withCurrency: currency!)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .top)
            self.deleteAccount(atIndex: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = self.transactionsDataSource,
        let accnts = self.accounts else { return }
        dataSource.accountsFilter = [accnts[indexPath.row]]
        self.transactionsPresenter?.presentTransactions(presentingVC: self, dataSource: dataSource)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AccountsTableViewController: NewAccountViewControllerDelegate {
    func shouldCreateAccount(withId id: String?, name: String, type: AccountType,
                             initBalance: Double, dateOpened: Date,
                             color: UIColor) {
        do {
            try presenter?.createAccount(withId: id, name: name, type: type,
                                         initBalance: initBalance, dateOpened: dateOpened,
                                         color: color)
        } catch let errorMsg {
            showError(msg: errorMsg.localizedDescription)
        }
    }
    
    private func showError(msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("Ok", comment: "'Ok' action of an alert"),
                               style: .default,
                               handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
