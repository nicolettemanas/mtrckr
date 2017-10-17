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
    }
}
