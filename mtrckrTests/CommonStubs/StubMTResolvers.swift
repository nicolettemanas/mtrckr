//
//  StubViewControllerResolvers.swift
//  mtrckrTests
//
//  Created by User on 8/10/17.
//

import UIKit
import Swinject
@testable import mtrckr

class StubMTResolvers: MTResolver {
    override init() {
        super.init()
        container.register(TransactionsTableViewController.self, name: "stub") { (
            resolver,
            filter: TransactionsFilter) in
            
            TransactionsTableViewController
                .initWith(dataSource: resolver.resolve(TransactionsListDataSource.self,
                                                       name: "stub",
                                                       argument: filter),
                          newTransPresenter     : resolver.resolve(NewTransactionPresenter.self),
                          deleteTransPresenter  : resolver.resolve(DeleteTransactionSheetPresenter.self),
                          transactionsPresenter : resolver.resolve(TransactionsPresenter.self),
                          emptyDataSource       : resolver.resolve(EmptyTransactionsDataSource.self))
        }
        
        container.register(TransactionsListDataSource.self, name: "stub") { (
            _,
            filter: TransactionsFilter) in
            
            StubTransactionsListDataSource
                .init(authConfig    : self.authConfig,
                      filterBy      : filter,
                      date          : nil,
                      accounts      : [Account]())
        }
        
        container.register(NewAccountFormVC.self, name: "testable") {
            (resolver,
            account: Account?) in
            let vc = NewAccountFormVC.init(account: account,
                                           delegate: nil,
                                           accntTypeDatasource:
                resolver.resolve(AccountTypeCollectionDataSource.self, argument: nil as AccountType?)!)
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
        
        container.register(BillsInteractor.self, name: "mock") { _ in MockBillsInteractor(with: RealmAuthConfig()) }
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
            let vc = resolver.resolve(BillHistoryViewController.self, argument: bill)!
            
            let dataSource = resolver.resolve(BillHistoryDataSource.self, arguments: bill, identifier)
            vc.dataSource = dataSource
            vc.presenter = resolver.resolve(BillsPresenter.self, name: "mock", argument: identifier)
            return vc
            }.initCompleted { (_, vc) in
                vc.dataSource?.cellDelegate = vc
        }
        
        container.register(BillHistoryDataSource.self) { (
            resolver,
            bill: Bill,
            identifier: String) in
            
            let dataSource = resolver.resolve(BillHistoryDataSourceProtocol.self, argument: bill)
                as! BillHistoryDataSource
            dataSource.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
            dataSource.realmContainer?.setDefaultRealm(to: .offline)
            
            return dataSource
        }
    }
}
