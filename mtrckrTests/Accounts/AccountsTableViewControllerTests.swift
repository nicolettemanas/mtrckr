//
//  AccountsViewControllerTests.swift
//  mtrckrTests
//
//  Created by User on 6/27/17.
//

import UIKit
import Quick
import Nimble
@testable import mtrckr

class AccountsTableViewControllerTests: QuickSpec {
    var storyboard: UIStoryboard?
    var accountsVC: MTAccountsTableViewController?
    var mockPresenter: MockAccountsPresenter?
    
    override func spec() {
        beforeEach {
            self.storyboard = UIStoryboard(name: "Accounts", bundle: Bundle.main)
            self.accountsVC = self.storyboard?.instantiateViewController(withIdentifier: "MTAccountsTableViewController")
                                as? MTAccountsTableViewController
            self.mockPresenter = MockAccountsPresenter()
            self.accountsVC?.presenter = self.mockPresenter
            self.accountsVC?.beginAppearanceTransition(true, animated: false)
            self.accountsVC?.endAppearanceTransition()
        }
    
        describe("AccountsTableViewController") {
            it("Displays same number of accounts returned by presenter") {
                let accounts = self.mockPresenter?.accounts()
                expect(self.accountsVC?.tableView(self.accountsVC!.tableView!, numberOfRowsInSection: 0))
                    == accounts?.count
                
            }
            
            context("Taps + button/Pulls down to create account") {
                it("Informs presenter to display create account form") {
                    self.accountsVC?.createNewAccount()
                    expect(self.mockPresenter?.didShowCreateAccount) == true
                }
            }
            
            context("Chooses to edit an account") {
                it("Informs presenter to display edit account form") {
                    self.accountsVC?.editAccount(with: "id1")
                    expect(self.mockPresenter?.didShowEditAccount) == true
                    expect(self.mockPresenter?.editAccountId) == "id1"
                }
            }
        }
        
    }
}
