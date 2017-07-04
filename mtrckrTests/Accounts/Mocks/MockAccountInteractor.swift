//
//  MockAccountInteractor.swift
//  mtrckrTests
//
//  Created by User on 7/4/17.
//

import UIKit
@testable import mtrckr
import RealmSwift
import Realm

class MockAccountInteractor: AccountsInteractor {
    override func createAccount(account: Account) {
        if let acc = Account.with(key: account.id, inRealm: realmContainer!.userRealm!) {
            updateAccount(fromAccount: acc, toAccount: account)
        } else {
            account.save(toRealm: realmContainer!.userRealm!)
        }
    }
    
    override func updateAccount(fromAccount old: Account, toAccount new: Account) {
        old.update(to: new, in: realmContainer!.userRealm!)
    }
    
    override func accounts() -> Results<Account> {
        return Account.all(in: realmContainer!.userRealm!)
    }
    
    override func deleteAccount(account: Account) {
        account.delete(in: realmContainer!.userRealm!)
    }
    
    override func currency() -> String {
        return realmContainer?.currency() ?? "₱"
    }
}
