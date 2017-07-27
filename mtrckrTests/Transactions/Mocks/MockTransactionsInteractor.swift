//
//  MockTransactionsInteractor.swift
//  mtrckrTests
//
//  Created by User on 7/27/17.
//

import UIKit
import RealmSwift
@testable import mtrckr

class MockTransactionsInteractor: TransactionsInteractor {
    
    var didEdit = false
    var didDelete = false
    var didSave = false
    
    var receivedTransaction: Transaction?

    override func currency() -> String {
        return "###"
    }
    
    override func transactions(from date: Date) -> Results<Transaction> {
        return Transaction.all(in: realmContainer!.userRealm!, onDate: Date(timeIntervalSince1970: 0))
    }
    
    override func transactions(fromAccount account: [Account]) -> Results<Transaction> {
        return Transaction.all(in: realmContainer!.userRealm!, onDate: Date(timeIntervalSince1970: 0))
    }
    
    override func editTransaction(transaction: Transaction) throws {
        didEdit = true
        receivedTransaction = transaction
    }
    
    override func deleteTransaction(transaction: Transaction) {
        didDelete = true
        receivedTransaction = transaction
    }
    
    override func saveTransaction(transaction: Transaction) {
        didSave = true
        receivedTransaction = transaction
    }
    
}
