//
//  StubViewControllerResolvers.swift
//  mtrckrTests
//
//  Created by User on 8/10/17.
//

import UIKit
import Swinject
@testable import mtrckr

class StubMTResolvers {
    static let shared = StubMTResolvers()
    let container = Container()
    private init() {
        container.register(TransactionsTableViewController.self, name: "stub") { (
            resolver,
            filter: TransactionsFilter) in
            
            TransactionsTableViewController
                .initWith(dataSource: resolver.resolve(TransactionsListDataSource.self,
                                                       name: "stub",
                                                       argument: filter),
              newTransPresenter     : MTResolver.shared.transactions.resolve(NewTransactionPresenter.self),
              deleteTransPresenter  : MTResolver.shared.transactions.resolve(DeleteTransactionSheetPresenter.self),
              transactionsPresenter : MTResolver.shared.transactions.resolve(TransactionsPresenter.self),
              emptyDataSource       : MTResolver.shared.transactions.resolve(EmptyTransactionsDataSource.self))
        }
        
        container.register(TransactionsListDataSource.self, name: "stub") { (
            _,
            filter: TransactionsFilter) in
            
            StubTransactionsListDataSource
                .init(authConfig    : RealmAuthConfig(),
                      filterBy      : filter,
                      date          : nil,
                      accounts      : [Account]())
        }
        
        container.register(NewAccountFormVC.self, name: "testable") {
            (_,
            account: Account?) in
            let vc = NewAccountFormVC.init(account: account,
                                           delegate: nil,
                                           accntTypeDatasource:
                MTResolver.shared.accounts
                    .resolve(AccountTypeCollectionDataSource.self, argument: nil as AccountType?)!)
            return vc
        }
        
        container.register(BillsTableViewController.self, name: "stub") { (
            resolver,
            dataSource: BillsDataSourceProtocol)  in
            
            BillsTableViewController
                .initWith(dataSource            : dataSource,
                          emptyDataSource       : EmptyBillsDataSource(),
                          newBillPresenter      : resolver.resolve(BillVCPresenter.self, name: "mock")!,
                          deleteBillPresenter   : resolver.resolve(DeleteBillPresenter.self, name: "mock")!,
                          presenter             : resolver.resolve(BillsPresenter.self, name: "mock")!)
            }.initCompleted { (_, viewController) in
                viewController.dataSource?.delegate = viewController
        }
        
        container.register(BillVCPresenter.self, name: "mock") { _ in MockBillVCPresenter() }
        container.register(BillsDataSource.self, name: "mock") { (_, identifier: String) in
            let source = BillsDataSource(with: RealmAuthConfig())
            source.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
            source.realmContainer?.setDefaultRealm(to: .offline)
            return source
        }
        
        container.register(BillsInteractor.self, name: "stub") { (_, identifier: String) in
            let interactor = BillsInteractor(with: RealmAuthConfig())
            interactor.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
            interactor.realmContainer?.setDefaultRealm(to: .offline)
            return interactor
        }
        
        container.register(BillsInteractor.self, name: "mock") { _ in
            MockBillsInteractor(with: RealmAuthConfig()) }
        container.register(DeleteBillPresenter.self, name: "mock") { _ in MockDeleteBillPresenter() }
        container.register(BillsPresenter.self, name: "mock") { resolver in
            MockBillsPresenter
                .init(interactor: resolver.resolve(BillsInteractor.self,
                                                   name     : "stub",
                                                   argument : "MockBillsPresenter")!)
        }
        
        container.register(BillsPresenter.self, name: "mock") { (
            resolver,
            identifier: String) in
            MockBillsPresenter
                .init(interactor: resolver.resolve(BillsInteractor.self,
                                                   name     : "stub",
                                                   argument : identifier)!)
        }
        
        container.register(BillHistoryViewController.self, name: "testable") { (
            resolver,
            bill: Bill,
            identifier: String) in
            let vc = MTResolver.shared.bills.resolve(BillHistoryViewController.self, argument: bill)!
            
            let dataSource = MTResolver.shared.bills
                .resolve(BillHistoryDataSource.self, arguments: bill, identifier)
            vc.dataSource = dataSource
            vc.presenter = resolver.resolve(BillsPresenter.self, name: "mock", argument: identifier)
            return vc
            }.initCompleted { (_, vc) in
                vc.dataSource?.cellDelegate = vc
        }
        
        MTResolver.shared.bills.register(BillHistoryDataSource.self) { (
            _,
            bill: Bill,
            identifier: String) in
            
            let dataSource = MTResolver.shared.bills
                .resolve(BillHistoryDataSourceProtocol.self, argument: bill)
                as! BillHistoryDataSource
            dataSource.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
            dataSource.realmContainer?.setDefaultRealm(to: .offline)
            
            return dataSource
        }
    }
}
