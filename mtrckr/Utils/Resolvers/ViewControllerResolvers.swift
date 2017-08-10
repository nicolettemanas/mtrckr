//
//  ViewControllerResolvers.swift
//  mtrckr
//
//  Created by User on 8/10/17.
//

import UIKit
import Swinject

class ViewControllerResolvers {
    var container = Container()
    var authConfig = RealmAuthConfig()
    
    init() {
        container.register(TransactionsTableViewController.self) { (resolver, filter: TransactionsFilter) in
            TransactionsTableViewController.initWith(dataSource: resolver.resolve(TransactionsListDataSource.self, argument: filter),
            newTransPresenter: NewTransactionPresenter(),
            deleteTransPresenter: DeleteTransactionSheetPresenter(),
            transactionsPresenter: resolver.resolve(TransactionsPresenter.self),
            emptyDataSource: EmptyTransactionsDataSource())
        }
        
        container.register(TransactionsInteractor.self) { _ in
            TransactionsInteractor(with: self.authConfig)
        }
        
        container.register(TransactionsPresenter.self) { resolver in
            TransactionsPresenter(with: resolver.resolve(TransactionsInteractor.self)!)
        }
        
        container.register(TransactionsListDataSource.self) { (_, filter: TransactionsFilter) in
            TransactionsListDataSource(authConfig: self.authConfig,
                                              filterBy: filter,
                                              date: nil,
                                              accounts: [Account]())
        }
    }
    
    func transactionTableViewController(filterType: TransactionsFilter) -> TransactionsTableViewController? {
        return self.container.resolve(TransactionsTableViewController.self, argument: filterType)
    }
}
