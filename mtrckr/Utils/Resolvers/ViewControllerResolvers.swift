//
//  ViewControllerResolvers.swift
//  mtrckr
//
//  Created by User on 8/10/17.
//

import UIKit
import Swinject

class MTResolver {
    let container = Container()
    let authConfig = RealmAuthConfig()
    
    init() {
        let filePath = RealmAuthConfig().offlineRealmFileName
        if !FileManager.default.fileExists(atPath: filePath) {
            InitialRealmGenerator.generateInitRealm { (_) in
                let holder = RealmContainer(withConfig: RealmAuthConfig())
                _ = holder.userRealm
                registerAll()
            }
        } else { registerAll() }
    }
    
    func registerAll() {
        registerTransactions()
        registerAccounts()
        registerBills()
    }
    
    private func registerTransactions() {
        container.register(TransactionsTableViewController.self) {
            (resolver, dataSource: TransactionsListDataSourceProtocol) in
            TransactionsTableViewController
                .initWith(dataSource: dataSource,
                 newTransPresenter: resolver.resolve(NewTransactionPresenter.self),
                 deleteTransPresenter: resolver.resolve(DeleteTransactionSheetPresenter.self),
                 transactionsPresenter: resolver.resolve(TransactionsPresenter.self),
                 emptyDataSource: resolver.resolve(EmptyTransactionsDataSource.self))
        }
        
        container.register(TransactionsInteractor.self) { [unowned self] _ in
            TransactionsInteractor(with: self.authConfig)
        }
        
        container.register(TransactionsPresenter.self) { resolver in
            TransactionsPresenter(with: resolver.resolve(TransactionsInteractor.self)!)
        }
        
        container.register(TransactionsListDataSource.self)
        { [unowned self] (_, filter: TransactionsFilter, accounts: [Account]) in
            TransactionsListDataSource
                .init(authConfig    : self.authConfig,
                      filterBy      : filter,
                      date          : nil,
                      accounts      : accounts)
        }
        
        container.register(TransactionsListDataSource.self) {
            [unowned self] (_, filter: TransactionsFilter, date: Date) in
            TransactionsListDataSource
                .init(authConfig    : self.authConfig,
                      filterBy      : filter,
                      date          : date,
                      accounts      : [Account]())
        }
        
        container.register(NewTransactionPresenter.self) { _ in NewTransactionPresenter() }
        container.register(DeleteTransactionSheetPresenter.self) { _ in DeleteTransactionSheetPresenter() }
        container.register(EmptyTransactionsDataSource.self) { _ in EmptyTransactionsDataSource() }
    }
    
    private func registerAccounts() {
        container.register(AccountsTableViewController.self) { (resolver, dataSource: TransactionsListDataSourceProtocol) in
            AccountsTableViewController
                .initWith(presenter             : resolver.resolve(AccountsPresenter.self),
                         emptyDataSource        : EmptyAccountsDataSource(),
                         transactionsDataSource : dataSource,
                         newAccountPresenter    : NewAccountPresenter(),
                         deleteSheetPresenter   : DeleteSheetPresenter(),
                         transactionsPresenter  : AccountTransactionsPresenter())
            
        }
        
        container.register(AccountsPresenter.self) { resolver in
            AccountsPresenter(interactor: resolver.resolve(AccountsInteractor.self)!)
        }
        
        container.register(AccountsInteractor.self) { [unowned self] _ in
            AccountsInteractor(with: self.authConfig)
        }
        
        container.register(EmptyAccountsDataSource.self) { _ in EmptyAccountsDataSource() }
        container.register(NewAccountPresenter.self) { _ in NewAccountPresenter() }
        container.register(DeleteSheetPresenter.self) { _ in DeleteSheetPresenter() }
        container.register(AccountTransactionsPresenter.self) { _ in AccountTransactionsPresenter() }
    }
    
    private func registerBills() {
        container.register(BillsTableViewController.self) { resolver in
            BillsTableViewController
                .initWith(dataSource            : resolver.resolve(BillsDataSource.self)!,
                          emptyDataSource       : resolver.resolve(EmptyBillsDataSource.self)!,
                          newBillPresenter      : resolver.resolve(BillVCPresenter.self)!,
                          deleteBillPresenter   : resolver.resolve(DeleteBillPresenter.self)!,
                          presenter             : resolver.resolve(BillsPresenter.self)!)
            
        }.initCompleted { (_, vc) in
            vc.dataSource?.delegate = vc
        }
        
        container.register(PayBillViewController.self) {
            (resolver, entry: BillEntry, delegate: PayBillPresenterDelegate) in
            let vc = PayBillViewController
                .initWith(billEntry : entry,
                          accPrsntr : resolver.resolve(AccountsPresenter.self)!)
            vc.delegate = delegate
            return vc
        }
        
        container.register(NewBillViewController.self) {
            (_, delegate: NewBillViewControllerDelegate, entry: BillEntry?) in
            let vc = NewBillViewController.initWith(delegate: delegate)
            vc.billEntry = entry
            return vc
        }
        
        container.register(BillsDataSource.self) { _ in BillsDataSource(with: RealmAuthConfig()) }
        container.register(EmptyBillsDataSource.self) { _ in EmptyBillsDataSource() }
        container.register(BillVCPresenter.self) { _ in BillVCPresenter() }
        container.register(DeleteBillPresenter.self) { _ in DeleteBillPresenter() }
        container.register(BillsPresenter.self) { resolver in
            BillsPresenter(interactor: resolver.resolve(BillsInteractor.self)!)
        }
        container.register(BillsInteractor.self) { _ in BillsInteractor(with: RealmAuthConfig()) }
    }
}
