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

class AccountsInteractor: RealmHolder, AccountsInteractorProtocol {
    
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
    
    func updateAccount(fromAccount old: Account, toAccount new: Account) {
        old.update(to: new, in: realmContainer!.userRealm!)
    }
    
    func accounts() -> Results<Account> {
        return Account.all(in: realmContainer!.userRealm!)
    }
    
    func deleteAccount(account: Account) {
        account.delete(in: realmContainer!.userRealm!)
    }
    
    func currency() -> String {
        return realmContainer?.currency() ?? "₱"
    }
}
