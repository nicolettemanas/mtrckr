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
        let filePath = RealmAuthConfig().offlineRealmFileName
        if !FileManager.default.fileExists(atPath: filePath) {
            InitialRealmGenerator.generateInitRealm { (_) in
                let holder = RealmContainer(withConfig: RealmAuthConfig())
                _ = holder.userRealm
                registerTransactions()
                registerAccounts()
            }
        } else {
            registerTransactions()
            registerAccounts()
        }
    }
    
    func registerTransactions() {
        container.register(TransactionsTableViewController.self) { (resolver, dataSource: TransactionsListDataSourceProtocol) in
            TransactionsTableViewController.initWith(dataSource: dataSource,
                                                     newTransPresenter: resolver.resolve(NewTransactionPresenter.self),
                                                     deleteTransPresenter: resolver.resolve(DeleteTransactionSheetPresenter.self),
                                                     transactionsPresenter: resolver.resolve(TransactionsPresenter.self),
                                                     emptyDataSource: resolver.resolve(EmptyTransactionsDataSource.self))
        }
        
        container.register(TransactionsInteractor.self) { _ in
            TransactionsInteractor(with: self.authConfig)
        }
        
        container.register(TransactionsPresenter.self) { resolver in
            TransactionsPresenter(with: resolver.resolve(TransactionsInteractor.self)!)
        }
        
        container.register(TransactionsListDataSource.self) { (_, filter: TransactionsFilter, accounts: [Account]) in
            TransactionsListDataSource(authConfig: self.authConfig,
                                       filterBy: filter,
                                       date: nil,
                                       accounts: accounts)
        }
        
        container.register(TransactionsListDataSource.self) { (_, filter: TransactionsFilter, date: Date) in
            TransactionsListDataSource(authConfig: self.authConfig,
                                       filterBy: filter,
                                       date: date,
                                       accounts: [Account]())
        }
        
        container.register(NewTransactionPresenter.self) { _ in
            NewTransactionPresenter()
        }
        
        container.register(DeleteTransactionSheetPresenter.self) { _ in
            DeleteTransactionSheetPresenter()
        }
        
        container.register(EmptyTransactionsDataSource.self) { _ in
            EmptyTransactionsDataSource()
        }
    }
    
    func registerAccounts() {
        container.register(AccountsTableViewController.self) { (resolver, dataSource: TransactionsListDataSourceProtocol) in
            AccountsTableViewController.initWith(presenter: resolver.resolve(AccountsPresenter.self),
                                                 emptyDataSource: EmptyAccountsDataSource(),
                                                 transactionsDataSource: dataSource,
                                                 newAccountPresenter: NewAccountPresenter(),
                                                 deleteSheetPresenter: DeleteSheetPresenter(),
                                                 transactionsPresenter: AccountTransactionsPresenter())
            
        }
        
        container.register(AccountsPresenter.self) { resolver in
            AccountsPresenter(interactor: resolver.resolve(AccountsInteractor.self)!)
        }
        
        container.register(AccountsInteractor.self) { _ in
            AccountsInteractor(with: self.authConfig)
        }
        
        container.register(EmptyAccountsDataSource.self) { _ in
            EmptyAccountsDataSource()
        }
        
        container.register(NewAccountPresenter.self) { _ in
            NewAccountPresenter()
        }
        
        container.register(DeleteSheetPresenter.self) { _ in
            DeleteSheetPresenter()
        }
        
        container.register(AccountTransactionsPresenter.self) { _ in
            AccountTransactionsPresenter()
        }
    }
}
