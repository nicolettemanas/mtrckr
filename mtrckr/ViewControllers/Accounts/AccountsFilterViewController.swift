//
//  AccountsFilterViewController.swift
//  mtrckr
//
//  Created by User on 8/14/17.
//

import UIKit
import Eureka

protocol AccountsFilterViewControllerDelegate: class {
    func didSelectAccounts(accounts: [Account])
}

class AccountsFilterViewController: FormViewController {
    var accounts = [Account]()
    var section: SelectableSection<ListCheckRow<Account>>?
    var rows = [ListCheckRow<Account>]()
    weak var delegate: AccountsFilterViewControllerDelegate?

    @IBAction func selectAll(sender: UIButton) {
        for row in rows {
            row.select()
            row.didSelect()
        }
    }

    @IBAction func didPressDone(sender: UIButton) {
        if let selectedRows = section?.selectedRows() {
            var selectedAccounts = [Account]()
            for row in selectedRows {
                selectedAccounts.append(row.value!)
            }
            delegate?.didSelectAccounts(accounts: selectedAccounts.count == accounts.count ? [] : selectedAccounts)
        }

        dismiss(animated: true, completion: nil)
    }

    static func create(with accounts: [Account],
                       delegate: AccountsFilterViewControllerDelegate?) -> AccountsFilterViewController {
        let storyboard = UIStoryboard(name: "Today", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AccountsFilterViewController")
            as? AccountsFilterViewController
        else {
            fatalError("Cannot cast UIViewController as AccountsFilterViewController")
        }
        vc.accounts = accounts
        vc.delegate = delegate
        return vc
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        section = SelectableSection<ListCheckRow<Account>>("Filter by accounts",
                                                           selectionType: SelectionType.multipleSelection)
        guard let sec = section else { fatalError("Cannot initialize SelectableSection") }
        form +++ sec
        for account in accounts {
            sec <<< ListCheckRow<Account> { [unowned self] listRow in
                listRow.title = account.name
                listRow.selectableValue = account
                listRow.value = nil
                self.rows.append(listRow)
            }
        }
    }
}

protocol AccountsFilterPresenterProtocol {
    func presentSelection(accounts: [Account], presentingVC: AccountsFilterViewControllerDelegate)
}

class AccountsFilterPresenter: AccountsFilterPresenterProtocol {
    func presentSelection(accounts: [Account], presentingVC: AccountsFilterViewControllerDelegate) {
        let navVC = UINavigationController()
        let filterVC = AccountsFilterViewController.create(with: accounts, delegate: presentingVC)
        navVC.setViewControllers([filterVC], animated: false)
        (presentingVC as? UIViewController)?.present(navVC, animated: true, completion: nil)
    }
}
