//
//  AccountTransactionsPresenterTests.swift
//  mtrckrTests
//
//  Created by User on 8/11/17.
//

import UIKit
import Quick
import Nimble
@testable import mtrckr

class AccountTransactionsPresenterTests: QuickSpec {
    override func spec() {
        describe("AccountTransactionsPresenter") {
            context("asked to present transaction view controller with accounts filter", closure: {
                
                var presenter: AccountTransactionsPresenter!
                var vc: AccountsTableViewController!
                var dataSource: StubTransactionsListDataSource!
                var stubResolver: StubViewControllerResolvers!
                
                beforeEach {
                    stubResolver = StubViewControllerResolvers()
                    presenter = AccountTransactionsPresenter()
                    dataSource = stubResolver.container.resolve(TransactionsListDataSource.self, name: "stub",
                                                                argument: TransactionsFilter.byAccount)! as! StubTransactionsListDataSource
                    vc = stubResolver.container.resolve(AccountsTableViewController.self,
                                                        argument: dataSource as TransactionsListDataSourceProtocol)
                }
                
                it("calls reloadByAccounts", closure: {
                    let acc = FakeModels().account()
                    dataSource.accountsFilter = [acc]
                    presenter.presentTransactions(presentingVC: vc, dataSource: dataSource)
                    expect(dataSource.didReloadAccounts) == true
                    expect(dataSource.accountsReloaded.count) == 1
                    expect(dataSource.accountsReloaded.first) == acc
                })
            })
        }
    }
}
