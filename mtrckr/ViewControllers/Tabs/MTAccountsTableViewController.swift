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

class MTAccountsTableViewController: MTTableViewController, MTAccountsTableViewControllerProtocol,
NewAccountViewControllerDelegate, AccountsPresenterOutput {
    
    var presenter: AccountsPresenterProtocol?
    var accounts: [Account] = []
    var currency: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAccounts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let interactor = AccountsInteractor(with: RealmAuthConfig())
        presenter = AccountsPresenter(interactor: interactor, output: self)
        
        interactor.output = presenter as? AccountsInteractorOutput
        tableView.register(UINib(nibName: "AccountTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "AccountTableViewCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = MTColors.placeholderText
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        
        currency = presenter?.currency()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func addAccountBtnPressed(_ sender: Any) {
        createNewAccount()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell") as? AccountTableViewCell else {
            fatalError("Cannot initialize AccountTableViewCell")
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency
        
        let a = accounts[indexPath.row]
        cell.nameLabel.text = a.name
        cell.amountLabel.text = "\(formatter.string(from: a.currentAmount as NSNumber)!)"
        cell.typeView.backgroundColor = UIColor(a.color)
        cell.typeImageView.image = UIImage(named: a.type!.icon)
        cell.typeLabel.text = a.type!.name
        return cell
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
    
    func editAccount(with id: String) {
        presenter?.showEditAccount(with: id)
    }
    
    // MARK: - NewAccountViewControllerDelegate methods
    func shouldCreateAccount(withName name: String, type: AccountType,
                             initBalance: Double, dateOpened: Date,
                             color: UIColor) {
        presenter?.createAccount(withName: name, type: type,
                                 initBalance: initBalance, dateOpened: dateOpened,
                                 color: color)
    }
    
    // MARK: - AccountsPresenterOutput methods
    func updateAccounts() {
        DispatchQueue.main.async {
            self.accounts = self.presenter!.accounts()
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }

}
