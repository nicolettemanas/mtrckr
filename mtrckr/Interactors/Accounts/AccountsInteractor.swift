// 
//  AccountsInteractor.swift
//  mtrckr
//
//  Created by User on 6/30/17.
//

import UIKit
import Realm
import RealmSwift

// source: https://stackoverflow.com/a/40629365
/// :nodoc:
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

protocol AccountsInteractorProtocol {
    func currency() -> String
    func createAccount(account: Account) throws
    func accounts() -> Results<Account>
    func deleteAccount(account: Account)
    func updateAccount(fromAccount old: Account, toAccount new: Account)
}

/// Class responsible for `Account` modification methods
class AccountsInteractor: RealmHolder, AccountsInteractorProtocol {
    
    /// Checks if an `Account` already exists in the `Realm`. Creates if not, updates if existing.
    /// Throws an error if the existing number of `Account`s is 20.
    ///
    /// - Parameter account: The `Account` to be created or updated
    /// - Throws: Throws a message saying that there is a limit of 20 `Account`s per user
    func createAccount(account: Account) throws {
        if let acc = Account.with(key: account.id, inRealm: realmContainer!.userRealm!) {
            updateAccount(fromAccount: acc, toAccount: account)
        } else {
            if Account.all(in: realmContainer!.userRealm!).count < 20 {
                account.save(toRealm: realmContainer!.userRealm!)
            } else {
                throw NSLocalizedString("Sorry. You cannot create more than 20 accounts.",
                                        comment: "Tells the user that account creation failed due to the 20-account limit")
            }
        }
    }
    
    /// Updates the old `Account` to the new one provided
    ///
    /// - Parameters:
    ///   - old: The old `Account` to be updated
    ///   - new: The new `Account` to be saved
    func updateAccount(fromAccount old: Account, toAccount new: Account) {
        old.update(to: new, in: realmContainer!.userRealm!)
    }
    
    /// Retrieves all `Account`s in the `Realm` sorted by name
    ///
    /// - Returns: All `Account`s fetched
    func accounts() -> Results<Account> {
        return Account.all(in: realmContainer!.userRealm!)
    }
    
    /// Deletes the account specified
    ///
    /// - Parameter account: The `Account` to be deleted
    func deleteAccount(account: Account) {
        account.delete(in: realmContainer!.userRealm!)
    }
    
    /// Retrieves the current currency symbol used by the user
    ///
    /// - Returns: The symbol of the currency being used. Default is `₱`
    func currency() -> String {
        return realmContainer?.currency() ?? "₱"
    }
}
