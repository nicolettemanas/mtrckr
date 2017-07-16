//
//  TransactionListPresenter.swift
//  mtrckr
//
//  Created by User on 7/5/17.
//

import UIKit
import Realm
import RealmSwift

protocol TransactionsPresenterProtocol {
    init(with int: TransactionsInteractor)
    
    func currency() -> String
    func transactions(from date: Date) -> Results<Transaction>
    func transactions(fromAccounts account: [Account]) -> Results<Transaction>
    func editTransaction(transaction: Transaction) throws
    func deleteTransaction(transaction: Transaction)
    func createTransaction(with name: String, amount: Double, type: TransactionType, date: Date,
                           category: Category?, from sourceAcc: Account, to destAccount: Account)
}

class TransactionsPresenter: TransactionsPresenterProtocol {
    
    private var interactor: TransactionsInteractorProtocol
    
    required init(with int: TransactionsInteractor) {
        interactor = int
    }
    
    func currency() -> String {
        return interactor.currency()
    }
    
    func transactions(from date: Date) -> Results<Transaction> {
        return interactor.transactions(from: date)
    }
    
    func transactions(fromAccounts account: [Account]) -> Results<Transaction> {
        return interactor.transactions(fromAccount: account)
    }
    
    func editTransaction(transaction: Transaction) throws {
        try interactor.editTransaction(transaction: transaction)
    }
    
    func deleteTransaction(transaction: Transaction) {
        interactor.deleteTransaction(transaction: transaction)
    }
    
    func createTransaction(with name: String, amount: Double, type: TransactionType, date: Date,
                           category: Category?, from sourceAcc: Account, to destAccount: Account) {
        let transaction = Transaction(type: type, name: name, image: nil, description: nil,
                                      amount: amount, category: category, from: sourceAcc,
                                      to: destAccount, date: date)
        interactor.saveTransaction(transaction: transaction)
    }
}
