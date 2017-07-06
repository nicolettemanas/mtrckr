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
    func transactions(fromAccount account: Account) -> Results<Transaction>
    func editTransaction(transaction: Transaction) throws
    func deleteTransaction(transaction: Transaction)
}

class TransactionsPresenter: TransactionsPresenterProtocol {
    
    private var interactor: TransactionsInteractorProtocol
    
    required init(with int: TransactionsInteractor) {
        interactor = int
    }
    
    func currency() -> String {
        return interactor.currency()
    }
    
    func transactions(fromAccount account: Account) -> Results<Transaction> {
        return interactor.transactions(fromAccount: account)
    }
    
    func editTransaction(transaction: Transaction) throws {
        try interactor.editTransaction(transaction: transaction)
    }
    
    func deleteTransaction(transaction: Transaction) {
        interactor.deleteTransaction(transaction: transaction)
    }
}
