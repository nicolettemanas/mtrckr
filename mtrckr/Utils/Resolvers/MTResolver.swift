//
//  ViewControllerResolvers.swift
//  mtrckr
//
//  Created by User on 8/10/17.
//

import UIKit
import Swinject

class MTResolver {
    static let shared = MTResolver()
    
    let transactions = Container()
    let accounts = Container()
    let bills = Container()
    
//    let container = Container()
    let authConfig = RealmAuthConfig()

    private init() {
        // TODO: Move this somewhere else
        // TODO: Make this a singleton
        
//        let filePath = RealmAuthConfig().offlineRealmFileName
//        if !FileManager.default.fileExists(atPath: filePath) {
//            InitialRealmGenerator.generateInitRealm { (_) in
//                let holder = RealmContainer(withConfig: RealmAuthConfig())
//                _ = holder.userRealm
//                registerAll()
//            }
//        } else { registerAll() }
        registerAll()
    }

    func registerAll() {
        registerTransactions()
        registerAccounts()
        registerBills()
    }
}

extension MTResolver {
    func registerTransactions() {
        transactions.register(TransactionsTableViewController.self) { (
            resolver,
            dataSource: TransactionsListDataSourceProtocol) in

            TransactionsTableViewController
                .initWith(dataSource    : dataSource,
                          newTransPresenter      : resolver.resolve(NewTransactionPresenter.self),
                          deleteTransPresenter   : resolver.resolve(DeleteTransactionSheetPresenter.self),
                          transactionsPresenter  : resolver.resolve(TransactionsPresenter.self),
                          emptyDataSource        : resolver.resolve(EmptyTransactionsDataSource.self))
        }

        transactions.register(TransactionsInteractor.self) { [unowned self] _ in
            TransactionsInteractor(with: self.authConfig)
        }

        transactions.register(TransactionsPresenter.self) { resolver in
            TransactionsPresenter(with: resolver.resolve(TransactionsInteractor.self)!)
        }

        transactions.register(TransactionsListDataSource.self) { [unowned self] (
            _,
            filter: TransactionsFilter,
            accounts: [Account]) in

            TransactionsListDataSource
                .init(authConfig    : self.authConfig,
                      filterBy      : filter,
                      date          : nil,
                      accounts      : accounts)
        }

        transactions.register(TransactionsListDataSource.self) { [unowned self] (
            _,
            filter: TransactionsFilter,
            date: Date) in

            TransactionsListDataSource
                .init(authConfig    : self.authConfig,
                      filterBy      : filter,
                      date          : date,
                      accounts      : [Account]())
        }

        transactions.register(NewTransactionPresenter.self) { _ in NewTransactionPresenter() }
        transactions.register(DeleteTransactionSheetPresenter.self) { _ in DeleteTransactionSheetPresenter() }
        transactions.register(EmptyTransactionsDataSource.self) { _ in EmptyTransactionsDataSource() }
    }
}

extension MTResolver {
    func registerAccounts() {
        accounts.register(AccountsTableViewController.self) { (
            resolver,
            dataSource: TransactionsListDataSourceProtocol?) in

            AccountsTableViewController
                .initWith(presenter             : resolver.resolve(AccountsPresenter.self),
                          emptyDataSource        : EmptyAccountsDataSource(),
                          transactionsDataSource : dataSource,
                          newAccountPresenter    : NewAccountPresenter(),
                          deleteSheetPresenter   : DeleteSheetPresenter(),
                          transactionsPresenter  : AccountTransactionsPresenter())

        }

        accounts.register(NewAccountFormVC.self) {
            (resolver,
            account: Account?,
            delegate: NewAccountViewControllerDelegate?) in

            return NewAccountFormVC(account: account, delegate: delegate,
                                    accntTypeDatasource: resolver
                                        .resolve(AccountTypeCollectionDataSource.self, argument: account?.type)!)
        }

        accounts.register(AccountsPresenter.self) { resolver in
            AccountsPresenter(interactor: resolver.resolve(AccountsInteractor.self)!)
        }

        accounts.register(AccountsInteractor.self) { [unowned self] _ in
            AccountsInteractor(with: self.authConfig)
        }

        accounts.register(AccountTypeCollectionDataSource.self) {
            (_,
            accountType: AccountType?) in
            AccountTypeCollectionDataSource(with: self.authConfig, value: accountType)
        }

        accounts.register(EmptyAccountsDataSource.self) { _ in EmptyAccountsDataSource() }
        accounts.register(NewAccountPresenter.self) { _ in NewAccountPresenter() }
        accounts.register(DeleteSheetPresenter.self) { _ in DeleteSheetPresenter() }
        accounts.register(AccountTransactionsPresenter.self) { _ in AccountTransactionsPresenter() }
    }
}

extension MTResolver {
    func registerBills() {
        bills.register(BillsTableViewController.self) { resolver in
            BillsTableViewController
                .initWith(dataSource            : resolver.resolve(BillsDataSource.self)!,
                          emptyDataSource       : resolver.resolve(EmptyBillsDataSource.self)!,
                          newBillPresenter      : resolver.resolve(BillVCPresenter.self)!,
                          deleteBillPresenter   : resolver.resolve(DeleteBillPresenter.self)!,
                          presenter             : resolver.resolve(BillsPresenter.self)!)

            }.initCompleted { (_, vc) in
                vc.dataSource?.delegate = vc
        }

        bills.register(PayBillViewController.self) { (
            _,
            entry: BillEntry,
            delegate: PayBillViewControllerDelegate) in

            let vc = PayBillViewController(billEntry: entry, delegate: delegate)
            return vc
        }

        bills.register(NewBillViewController.self) { (
            _,
            delegate: NewBillViewControllerDelegate,
            entry: BillEntry?) in

            let vc = NewBillViewController(entry: entry, delegate: delegate)
            return vc
        }

        bills.register(BillHistoryDataSourceProtocol.self) { (
            _,
            bill: Bill) in
            return BillHistoryDataSource(bill: bill)
        }

        bills.register(BillHistoryViewController.self) { (
            resolver,
            bill: Bill) in

            let vc = BillHistoryViewController(bill         : bill,
                                               dataSource   : resolver.resolve(BillHistoryDataSourceProtocol.self,
                                                                               argument: bill)!,
                                               presenter    : resolver.resolve(BillsPresenter.self)!)
            return vc
            }.initCompleted { (_, vc) in
                vc.dataSource?.cellDelegate = vc
        }

        bills.register(BillsDataSource.self) { _ in BillsDataSource(with: RealmAuthConfig()) }
        bills.register(EmptyBillsDataSource.self) { _ in EmptyBillsDataSource() }
        bills.register(BillVCPresenter.self) { _ in BillVCPresenter() }
        bills.register(DeleteBillPresenter.self) { _ in DeleteBillPresenter() }
        bills.register(BillsPresenter.self) { resolver in
            BillsPresenter(interactor: resolver.resolve(BillsInteractor.self)!)
        }
        bills.register(BillsInteractor.self) { _ in BillsInteractor(with: RealmAuthConfig()) }
    }
}
