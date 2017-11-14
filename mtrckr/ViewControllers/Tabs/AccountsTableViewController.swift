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

class AccountsTableViewController: MTTableViewController, AccountsTableViewControllerProtocol, UserObserver, NewAccountViewControllerDelegate {
    
    // MARK: - Properties
    // TODO: Implement Dwifft
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
        let resolver = MTResolver()
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
    
    // MARK: - NewAccountViewControllerDelegate
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
        let ok = MTAlertAction(title: NSLocalizedString("Ok", comment: "'Ok' action of an alert"),
                               style: .default,
                               handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

extension AccountsTableViewController {
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
        DispatchQueue.main.async {
            self.accounts = self.presenter?.accounts()
            self.notifToken = self.accounts?.addNotificationBlock(self.tableView.applyChanges)
            self.tableView.reloadData()
        }
    }
}
