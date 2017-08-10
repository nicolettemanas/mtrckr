//
//  StubViewControllerResolvers.swift
//  mtrckrTests
//
//  Created by User on 8/10/17.
//

import UIKit
import Swinject
@testable import mtrckr

class StubViewControllerResolvers: ViewControllerResolvers {
    override init() {
        super.init()
        container.register(TransactionsTableViewController.self, name: "stub") { (resolver, filter: TransactionsFilter) in
            TransactionsTableViewController.initWith(dataSource: resolver.resolve(TransactionsListDataSource.self, name: "stub",
                                                                                  argument: filter),
             newTransPresenter: NewTransactionPresenter(),
             deleteTransPresenter: DeleteTransactionSheetPresenter(),
             transactionsPresenter: resolver.resolve(TransactionsPresenter.self),
             emptyDataSource: EmptyTransactionsDataSource())
        }
        
        container.register(TransactionsListDataSource.self, name: "stub") { (_, filter: TransactionsFilter) in
            StubTransactionsListDataSource(authConfig: self.authConfig,
                                           filterBy: filter,
                                           date: nil,
                                           accounts: [Account]())
        }
    }
}
