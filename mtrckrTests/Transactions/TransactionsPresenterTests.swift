//
//  TransactionsPresenterTests.swift
//  mtrckrTests
//
//  Created by User on 8/6/17.
//

import UIKit
import Quick
import Nimble
@testable import mtrckr

class TransactionsPresenterTests: QuickSpec {
    override func spec() {
        var transactionsPresenter: TransactionsPresenter?
        var mockTransactionsInteractor: MockTransactionsInteractor?
        var fakeModels: FakeModels!
        
        let identifier = "TransactionsPresenterTests"
        
        beforeEach {
            mockTransactionsInteractor = MockTransactionsInteractor(with: RealmAuthConfig())
            mockTransactionsInteractor?.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
            mockTransactionsInteractor?.realmContainer?.setDefaultRealm(to: .offline)
            fakeModels = FakeModels()
            
            transactionsPresenter = TransactionsPresenter(with: mockTransactionsInteractor!)
        }
        
        describe("TransactionsPresenter") {
            describe("retrieving currency used", {
                beforeEach {
                    _ = transactionsPresenter?.currency()
                }
                
                it("asks interactor to retrieve currency", closure: {
                    expect(mockTransactionsInteractor?.didGetCurrency) == true
                })
            })
            
            describe("retrieving transactions from given date", {
                let date = Date()
                beforeEach {
                    _ = transactionsPresenter?.transactions(from: date)
                }
                
                it("asks interactor to retrieve transactions from date", closure: {
                    expect(mockTransactionsInteractor?.didGetTransactions) == true
                    expect(mockTransactionsInteractor?.dateFilter) == date
                })
            })
            
            describe("retrieving transactions from given accounts", {
                var accounts: [Account] = []
                beforeEach {
                    accounts = [fakeModels.account()]
                    _ = transactionsPresenter?.transactions(fromAccounts: accounts)
                }
                
                it("asks interactor to retrieve transactions from date", closure: {
                    expect(mockTransactionsInteractor?.didGetTransactions) == true
                    expect(mockTransactionsInteractor?.accountsFilter) == accounts
                })
            })
            
            describe("deleting a transaction", {
                var transactionToDelete: Transaction!
                beforeEach {
                    transactionToDelete = fakeModels.transaction()
                    transactionsPresenter?.deleteTransaction(transaction: transactionToDelete)
                }
                
                it("asks interactor to delete transaction", closure: {
                    expect(mockTransactionsInteractor?.didDeleteTransaction) == true
                    expect(mockTransactionsInteractor?.transactionToDelete) == transactionToDelete
                })
            })
            
            describe("creating a transaction", {
                var name: String!
                var amount: Double!
                var type: TransactionType!
                var date: Date!
                var category: mtrckr.Category!
                var from: Account!
                var to: Account!
                
                beforeEach {
                    name = "name"
                    amount = 120.00
                    type = .expense
                    date = Date()
                    category = fakeModels.category()
                    from = Account()
                    to = Account()
                    transactionsPresenter?.createTransaction(with: name, amount: amount, type: type,
                                                             date: date, category: category, from: from, to: to)
                }
                
                it("converts vaues to transactions and asks interactor to save transaction", closure: {
                    expect(mockTransactionsInteractor?.didSaveTransaction) == true
                    expect(mockTransactionsInteractor?.transactionToSave?.name) == name
                    expect(mockTransactionsInteractor?.transactionToSave?.amount) == amount
                    expect(mockTransactionsInteractor?.transactionToSave?.type) == type.rawValue
                    expect(mockTransactionsInteractor?.transactionToSave?.transactionDate) == date
                })
                
            })
            
            describe("updating a transactoin", {
                var name: String!
                var amount: Double!
                var type: TransactionType!
                var date: Date!
                var category: mtrckr.Category!
                var from: Account!
                var to: Account!
                var transaction: Transaction!
                
                beforeEach {
                    name = "name"
                    amount = 120.00
                    type = .expense
                    date = Date()
                    category = fakeModels.category()
                    from = Account()
                    to = Account()
                    transaction = fakeModels.transaction()
                    transactionsPresenter?.update(transaction: transaction, withValues: name, amount: amount,
                                                  type: type, date: date, category: category, from: from, to: to)
                }
                
                it("converts values to transaction and asks interactor to update transaction", closure: {
                    expect(mockTransactionsInteractor?.didUpdateTransaction) == true
                    expect(mockTransactionsInteractor?.transactionToUpdate?.name) == name
                    expect(mockTransactionsInteractor?.transactionToUpdate?.amount) == amount
                    expect(mockTransactionsInteractor?.transactionToUpdate?.type) == type.rawValue
                    expect(mockTransactionsInteractor?.transactionToUpdate?.transactionDate) == date
                })
            })
        }
    }
}
