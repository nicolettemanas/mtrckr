//
//  MTAccoutnsTableViewController.swift
//  mtrckr
//
//  Created by User on 6/27/17.
//

import UIKit

protocol MTAccountsTableViewControllerProtocol {
    var presenter: AccountsPresenterProtocol? { get set }
    func createNewAccount()
    func editAccount(with id: String)
}

class MTAccountsTableViewController: MTTableViewController, MTAccountsTableViewControllerProtocol {
    
    var presenter: AccountsPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    // MARK: - MTAccountsTableViewControllerProtocol methods
    func createNewAccount() {
        presenter?.showCreateAccount()
    }
    
    func editAccount(with id: String) {
        presenter?.showEditAccount(with: id)
    }

}
