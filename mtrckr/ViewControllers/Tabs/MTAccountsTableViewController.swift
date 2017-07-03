//
//  MTAccoutnsTableViewController.swift
//  mtrckr
//
//  Created by User on 6/27/17.
//

import UIKit
import SwipeCellKit
import Realm
import RealmSwift

protocol MTAccountsTableViewControllerProtocol {
    var presenter: AccountsPresenterProtocol? { get set }
    func createNewAccount()
}

class MTAccountsTableViewController: MTTableViewController, MTAccountsTableViewControllerProtocol,
                                    NewAccountViewControllerDelegate, UserObserver/*, AccountsPresenterOutput*/ {
    
    var presenter: AccountsPresenterProtocol?
    var accounts: Results<Account>?
    var currency: String?
    var notifToken: NotificationToken?
    var observer: ObserverProtocol?
    
    deinit {
        self.notifToken?.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let interactor = AccountsInteractor(with: RealmAuthConfig())
        presenter = AccountsPresenter(interactor: interactor)
        
        tableView.register(UINib(nibName: "AccountTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AccountTableViewCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = MTColors.placeholderText
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        
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

    @IBAction func addAccountBtnPressed(_ sender: Any) {
        createNewAccount()
    }
    
    // MARK: - Accounts modification methods
    func editAccount(atIndex indexPath: IndexPath) {
        let nav = storyboard?.instantiateViewController(withIdentifier: "NewAccountNavigationController")
        guard let vc = (nav as? UINavigationController)?.topViewController
            as? NewAccountViewController else {
                return
        }
        
        vc.delegate = self
        vc.account = accounts![indexPath.row]
        present(nav!, animated: true, completion: nil)
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
    
    // MARK: - Table view data source
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
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency
        
        let a = accounts![indexPath.row]
        cell.nameLabel.text = a.name
        cell.amountLabel.text = "\(formatter.string(from: a.currentAmount as NSNumber)!)"
        cell.typeView.backgroundColor = UIColor(a.color)
        cell.typeImageView.image = UIImage(named: a.type!.icon)
        cell.typeLabel.text = a.type!.name
        
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .top)
            self.deleteAccount(atIndex: indexPath)
        }
    }
    
    // MARK: - MTAccountsTableViewControllerProtocol methods
    func createNewAccount() {
        let nav = storyboard?.instantiateViewController(withIdentifier: "NewAccountNavigationController")
        guard let vc = (nav as? UINavigationController)?.topViewController
            as? NewAccountViewController else {
            return
        }
        
        vc.delegate = self
        present(nav!, animated: true, completion: nil)
    }
    
    func displayDeleteSheet(toDelete indexPath: IndexPath) {
        let deleteConfirmation = UIAlertController(title: nil,
                                                   message: NSLocalizedString("Are you sure you want to delete this account? " +
                                                    "Deleting an account deletes all associated transactions. " +
                                                    "This cannot be undone.",
                                                  comment: "A warning that indicates the deletion of transactions under" +
                                                    " the account to be deleted. Asks for user's confirmation."),
                                              preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Don't delete!", style: .cancel) { _ in
            deleteConfirmation.dismiss(animated: true, completion: nil)
        }
        
        let delete = UIAlertAction(title: "Yes, please.", style: .destructive) { _ in
            self.deleteAccount(atIndex: indexPath)
            
        }
        
        deleteConfirmation.addAction(cancel)
        deleteConfirmation.addAction(delete)
        
        present(deleteConfirmation, animated: true, completion: nil)
    }
    
    // MARK: - NewAccountViewControllerDelegate methods
    func shouldCreateAccount(withId id: String?, name: String, type: AccountType,
                             initBalance: Double, dateOpened: Date,
                             color: UIColor) {
        presenter?.createAccount(withId: id, name: name, type: type,
                                 initBalance: initBalance, dateOpened: dateOpened,
                                 color: color)
    }
}

extension MTAccountsTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .right {
            let edit = SwipeAction(style: .default, title: nil) { _, indexPath in
                self.editAccount(atIndex: indexPath)
            }
            
            edit.accessibilityLabel = "Edit"
            edit.image = #imageLiteral(resourceName: "edit")
            edit.backgroundColor = MTColors.mainBlue
            edit.textColor = .white
            
            let delete = SwipeAction(style: .destructive, title: nil, handler: { (_, _) in
                self.displayDeleteSheet(toDelete: indexPath)
            })
            
            delete.accessibilityLabel = "Delete"
            delete.image = #imageLiteral(resourceName: "trash")
            delete.backgroundColor = MTColors.mainRed
            delete.textColor = .white
            
            return [delete, edit]
        }
        
        return []
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .none
        options.transitionStyle = .border
        return options
    }
}
