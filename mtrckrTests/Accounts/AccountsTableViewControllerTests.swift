//
//  AccountsViewControllerTests.swift
//  mtrckrTests
//
//  Created by User on 6/27/17.
//

import UIKit
import Quick
import Nimble
import Realm
import RealmSwift
@testable import mtrckr

class AccountsTableViewControllerTests: QuickSpec {
    var storyboard: UIStoryboard?
    var accountsVC: AccountsTableViewController?
    
    var mockPresenter: MockAccountsPresenter?
    var mockInteractor: MockAccountsInteractor?
    
    var mockNewAccountPresenter: MockNewAccountPresenter?
    var mockDeleteSheetPresenter: MockDeleteSheetPresenter?
    var mockAccountsTransactionsPresenter: MockAccountTransactionsPresenter?
    
    var identifier = "AccountsTableViewControllerTests"
    
    override func spec() {
        beforeEach {
            let resolver = ViewControllerResolvers()
            let transDataSource: TransactionsListDataSourceProtocol = StubViewControllerResolvers().container
                .resolve(TransactionsListDataSource.self, name: "stub", argument: TransactionsFilter.byAccount)!
            self.accountsVC = resolver.container.resolve(AccountsTableViewController.self, argument: transDataSource)
            expect(self.accountsVC?.view).toNot(beNil())
        }
    
        describe("AccountsTableViewController") {
            var realm: Realm?
            var account: Account!

            beforeEach {
                var config = Realm.Configuration()
                config.inMemoryIdentifier = self.identifier
                realm = try? Realm(configuration: config)
                try! realm?.write {
                    realm!.deleteAll()
                }
                
                self.mockInteractor = MockAccountsInteractor(with: RealmAuthConfig())
                self.mockInteractor?.realmContainer = MockRealmContainer(memoryIdentifier: self.identifier)
                self.mockInteractor?.realmContainer?.setDefaultRealm(to: .offline)
                
                self.mockPresenter = MockAccountsPresenter(interactor: self.mockInteractor!)
                self.mockNewAccountPresenter = MockNewAccountPresenter()
                self.mockDeleteSheetPresenter = MockDeleteSheetPresenter()
                self.mockAccountsTransactionsPresenter = MockAccountTransactionsPresenter()
                
                self.accountsVC?.presenter = self.mockPresenter
                self.accountsVC?.newAccountPresenter = self.mockNewAccountPresenter
                self.accountsVC?.deleteSheetPresenter = self.mockDeleteSheetPresenter
                self.accountsVC?.transactionsPresenter = self.mockAccountsTransactionsPresenter
                
                account = FakeModels().account()
                account.save(toRealm: realm!)
                
                self.accountsVC?.accounts = Account.all(in: realm!)
                self.accountsVC?.tableView.reloadData()
            }
            
            it("Displays same number of accounts returned by presenter") {
                let accounts = self.mockPresenter?.accounts()
                expect(self.accountsVC?.tableView(self.accountsVC!.tableView!,
                                                  numberOfRowsInSection: 0)) == accounts?.count ?? 0
                expect(self.accountsVC?.transactionsDataSource).toNot(beNil())
            }
            
            context("Taps + button to create account") {
                it("Presents NewAccountTableViewController") {
                    self.accountsVC?.addAccountBtnPressed([])
                    expect(self.mockNewAccountPresenter!.didCallPresent) == true
                }
            }
            
            context("Chooses to edit the first account displayed") {
                it("Presents edit account form") {
                    self.accountsVC?.editAccount(atIndex: IndexPath(row: 0, section: 0))
                    expect(self.mockNewAccountPresenter!.didCallPresent) == true
                    expect(self.mockNewAccountPresenter!.didReceiveId) == account.id
                }
            }
            
            context("Chooses to delete the first account displayed", {
                beforeEach {
                    self.accountsVC?.confirmDelete(atIndex: IndexPath(row: 0, section: 0))
                }
                
                it("Displays delete action sheet", closure: {
                    expect(self.mockDeleteSheetPresenter!.didPresentDeleteSheet) == true
                    expect(self.mockDeleteSheetPresenter?.indexToDelete) == IndexPath(row: 0, section: 0)
                })
                
                context("User taps an account", {
                    beforeEach {
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.accountsVC?.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
                        self.accountsVC?.tableView(self.accountsVC!.tableView!, didSelectRowAt: indexPath)
                    }
                    
                    it("Tells presenter to display transactions under selected account", closure: {
                        expect(self.mockAccountsTransactionsPresenter?.didPresent) == true
                        expect(self.mockAccountsTransactionsPresenter?.didPresentId) == self.accountsVC?.accounts?.first?.id
                    })
                })
                
                context("User chooses to delete account", {
                    beforeEach {
                        self.accountsVC?.deleteSheetPresenter = DeleteSheetPresenter()
                        self.accountsVC?.deleteSheetPresenter?.action = MockAlertAction.self
                        self.accountsVC?.confirmDelete(atIndex: IndexPath(row: 0, section: 0))
                    }
                    
                    it("tells presenter to delete the account", closure: {
                        let controller: UIAlertController = self.accountsVC!.deleteSheetPresenter!.alert!
                        let deleteAction = controller.actions[1] as! MockAlertAction
                        deleteAction.mockHandler!(deleteAction)
                        expect(self.mockPresenter?.didDelete) == true
                        expect(self.mockPresenter?.deleteAccountId) == account.id
                    })
                })
                
                context("User chooses to cancel deletion", {
                    beforeEach {
                        self.accountsVC?.deleteSheetPresenter = DeleteSheetPresenter()
                        self.accountsVC?.deleteSheetPresenter?.action = MockAlertAction.self
                        self.accountsVC?.confirmDelete(atIndex: IndexPath(row: 0, section: 0))
                    }
                    
                    it("Does not delete account", closure: {
                        let controller: UIAlertController = self.accountsVC!.deleteSheetPresenter!.alert!
                        let deleteAction = controller.actions[0] as! MockAlertAction
                        deleteAction.mockHandler!(deleteAction)
                        expect(self.mockPresenter?.didDelete) == false
                        expect(self.mockPresenter?.deleteAccountId) == ""
                    })
                })
            })
        }
    }
}
