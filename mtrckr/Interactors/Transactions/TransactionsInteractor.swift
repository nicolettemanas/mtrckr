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

class TransactionsInteractor: RealmHolder, TransactionsInteractorProtocol {
    func transactions(from date: Date) -> Results<Transaction> {
        return Transaction.all(in: realmContainer!.userRealm!, onDate: date)
    }
    
    func currency() -> String {
        return realmContainer?.currency() ?? "₱"
    }
    
    func transactions(fromAccount account: [Account]) -> Results<Transaction> {
        return Transaction.all(in: realmContainer!.userRealm!, fromAccount: account[0])
    }
    
    func editTransaction(transaction: Transaction) throws {
        let realm = realmContainer!.userRealm!
        if let old = Transaction.with(key:  transaction.id, inRealm: realm) {
            old.updateTo(transaction: transaction, inRealm: realm)
        } else {
            throw NSLocalizedString("Oops, something went wrong while updating. Please try again.",
                                    comment: "Tells the user that something failed while updating and to try again.")
        }
    }
    
    func deleteTransaction(transaction: Transaction) {
        transaction.delete(in: realmContainer!.userRealm!)
    }
    
    func saveTransaction(transaction: Transaction) {
        transaction.save(toRealm: realmContainer!.userRealm!)
    }
}
