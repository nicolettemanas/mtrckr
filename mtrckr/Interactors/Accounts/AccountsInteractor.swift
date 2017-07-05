//
//  AccountsInteractor.swift
//  mtrckr
//
//  Created by User on 6/30/17.
//

import UIKit
import Realm
import RealmSwift

protocol AccountsInteractorProtocol {
    func currency() -> String
    func createAccount(account: Account)
    func accounts() -> Results<Account>
    func deleteAccount(account: Account)
    func updateAccount(fromAccount old: Account, toAccount new: Account)
}

class AccountsInteractor: RealmHolder, AccountsInteractorProtocol {
    
    func createAccount(account: Account) {
        if let acc = Account.with(key: account.id, inRealm: realmContainer!.userRealm!) {
            updateAccount(fromAccount: acc, toAccount: account)
        } else {
            account.save(toRealm: realmContainer!.userRealm!)
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
