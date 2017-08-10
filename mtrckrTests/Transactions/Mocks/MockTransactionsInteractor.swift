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
    
    var dateFilter: Date?
    var accountsFilter: [Account] = []
    var didGetCurrency = false
    var didGetTransactions = false
    var didUpdateTransaction = false
    var didDeleteTransaction = false
    var didSaveTransaction = false
    var transactionToUpdate: Transaction?
    var transactionToDelete: Transaction?
    var transactionToSave: Transaction?

    override func currency() -> String {
        didGetCurrency = true
        return "###"
    }
    
    override func transactions(from date: Date) -> Results<Transaction> {
        didGetTransactions = true
        dateFilter = date
        return Transaction.all(in: realmContainer!.userRealm!, onDate: Date(timeIntervalSince1970: 0))
    }
    
    override func transactions(fromAccount account: [Account]) -> Results<Transaction> {
        didGetTransactions = true
        accountsFilter = account
        return Transaction.all(in: realmContainer!.userRealm!, onDate: Date(timeIntervalSince1970: 0))
    }
    
    override func editTransaction(transaction: Transaction) throws {
        didUpdateTransaction = true
        transactionToUpdate = transaction
    }
    
    override func deleteTransaction(transaction: Transaction) {
        didDeleteTransaction = true
        transactionToDelete = transaction
    }
    
    override func saveTransaction(transaction: Transaction) {
        didSaveTransaction = true
        transactionToSave = transaction
    }
    
}
