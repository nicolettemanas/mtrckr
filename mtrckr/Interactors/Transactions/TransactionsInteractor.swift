//
//  TransactionsInteractor.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit
import RealmSwift
import Realm

protocol TransactionsInteractorProtocol {
    func currency() -> String
    func transactions(from date: Date) -> Results<Transaction>
    func transactions(fromAccount account: [Account]) -> Results<Transaction>
    func editTransaction(transaction: Transaction) throws
    func deleteTransaction(transaction: Transaction)
    func saveTransaction(transaction: Transaction)
}

/// Class responsible for handling modifications of `Transaction`
class TransactionsInteractor: RealmHolder, TransactionsInteractorProtocol {
    
    /// Retrieves a list of `Transactions` from a given date
    ///
    /// - Parameter date: The date filter
    /// - Returns: The list of `Transactions` fetched
    func transactions(from date: Date) -> Results<Transaction> {
        return Transaction.all(in: realmContainer!.userRealm!, onDate: date)
    }
    
    /// Returns the currency used
    ///
    /// - Returns: Currency used by the logged in user
    func currency() -> String {
        return realmContainer?.currency() ?? "₱"
    }
    
    /// Retrieves a list of `Transactions` from given `Accounts`
    ///
    /// - Parameter account: The `Accounts` filter
    /// - Returns: The list of `Transactions` fetched
    func transactions(fromAccount account: [Account]) -> Results<Transaction> {
        return Transaction.all(in: realmContainer!.userRealm!, fromAccount: account[0])
    }
    
    /// Updates a `Transaction`
    ///
    /// - Parameter transaction: The new `Transaction`
    /// - Throws: Throws an error when `Transaction` has been deleted
    func editTransaction(transaction: Transaction) throws {
        let realm = realmContainer!.userRealm!
        if let old = Transaction.with(key:  transaction.id, inRealm: realm) {
            old.updateTo(transaction: transaction, inRealm: realm)
        } else {
            throw NSLocalizedString("Oops, something went wrong while updating. Please try again.",
                                    comment: "Tells the user that something failed while updating and to try again.")
        }
    }
    
    /// Deletes a `Transaction` from the `Realm`
    ///
    /// - Parameter transaction: The `Transaction` to be deleted
    func deleteTransaction(transaction: Transaction) {
        transaction.delete(in: realmContainer!.userRealm!)
    }
    
    /// Saves a `Transaction` to the `Realm`
    ///
    /// - Parameter transaction: The `Transaction` to be saved
    func saveTransaction(transaction: Transaction) {
        transaction.save(toRealm: realmContainer!.userRealm!)
    }
}
