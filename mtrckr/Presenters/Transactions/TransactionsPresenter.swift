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
//    func editTransaction(transaction: Transaction) throws
    func deleteTransaction(transaction: Transaction)
    func createTransaction(with name: String, amount: Double, type: TransactionType, date: Date,
                           category: Category?, from sourceAcc: Account, to destAccount: Account)
    func update(transaction: Transaction, withValues name: String, amount: Double, type: TransactionType, date: Date,
                category: Category?, from sourceAcc: Account, to destAccount: Account)
}

class TransactionsPresenter: TransactionsPresenterProtocol {

    private var interactor: TransactionsInteractorProtocol

    required init(with int: TransactionsInteractor) {
        interactor = int
    }

    /// Returns the currency used by the user
    ///
    /// - Returns: The currency used the the user
    func currency() -> String {
        return interactor.currency()
    }

    /// Event handler for retrieving a list of `Transactions` from a given date
    ///
    /// - Parameter date: The date to be filtered
    /// - Returns: The `Transactions` recorded for the given day
    func transactions(from date: Date) -> Results<Transaction> {
        return interactor.transactions(from: date)
    }

    /// Event handler for retrieving a list of `Transactions` from given `Accounts`
    ///
    /// - Parameter account: An array of `Accounts` to filter the `Transactions` from
    /// - Returns: The filtered `Transactions`
    func transactions(fromAccounts account: [Account]) -> Results<Transaction> {
        return interactor.transactions(fromAccount: account)
    }

    /// Event handler for modifying a given `Transaction`
    ///
    /// - Parameter transaction: The updated `Transaction`
    /// - Throws: Throws an error if the `Transaction` is not found in the `Realm`
//    func editTransaction(transaction: Transaction) throws {
//        try interactor.editTransaction(transaction: transaction)
//    }

    /// Event handler for deleting a `Transaction`
    ///
    /// - Parameter transaction: the `Transaction` to be deleted
    func deleteTransaction(transaction: Transaction) {
        interactor.deleteTransaction(transaction: transaction)
    }

    /// Event handler for building a `Transaction` from the given values and tells the
    /// interactor to save it to the `Realm`
    ///
    /// - Parameters:
    ///   - name: The short description of the `Transaction`
    ///   - amount: The amount of the `Transaction`
    ///   - type: The type of the `Transaction`
    ///   - date: The date of the `Transaction`
    ///   - category: The category of the `Transaction`
    ///   - sourceAcc: The source `Account` of the `Transaction`
    ///   - destAccount: The destination `Account` of the `Transaction`
    func createTransaction(with name: String, amount: Double, type: TransactionType, date: Date,
                           category: Category?, from sourceAcc: Account, to destAccount: Account) {

        let transaction = Transaction(type: type, name: name, image: nil, description: nil,
                                      amount: amount, category: category, from: sourceAcc,
                                      to: destAccount, date: date)
        interactor.saveTransaction(transaction: transaction)
    }

    /// Event handler for updating a `Transaction`
    ///
    /// - Parameters:
    ///   - transaction: The `Transaction` to be updated
    ///   - name: The updated name of the `Transaction`
    ///   - amount: The updated amount of the `Transaction`
    ///   - type: The updated type of the `Transaction`
    ///   - date: The updated date of the `Transaction`
    ///   - category: The updated category of the `Transaction`
    ///   - sourceAcc: The updated source account of the `Transaction`
    ///   - destAccount: The updated destination account of the `Transaction`
    func update(transaction: Transaction, withValues name: String, amount: Double, type: TransactionType,
                date: Date, category: Category?, from sourceAcc: Account, to destAccount: Account) {
        let updatedTrans = Transaction(type: type, name: name, image: nil, description: nil,
                                      amount: amount, category: category, from: sourceAcc,
                                      to: destAccount, date: date)
        updatedTrans.id = transaction.id
        do {
            try interactor.editTransaction(transaction: updatedTrans)
        } catch {
            fatalError("Failed to update Transaction \(transaction.id)")
        }
    }
}
