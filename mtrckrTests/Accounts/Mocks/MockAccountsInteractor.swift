//
//  MockAccountsInteractor.swift
//  mtrckrTests
//
//  Created by User on 7/4/17.
//

import UIKit
@testable import mtrckr
import RealmSwift
import Realm

class MockAccountsInteractor: AccountsInteractor {
    var accountToDelete: Account?
    var accountToCreate: Account?
    var didRetrieveAccounts = false
    var didAskCurrency = false
    
    override func deleteAccount(account: Account) {
        accountToDelete = account
    }
    
    override func accounts() -> Results<Account> {
        didRetrieveAccounts = true
        return super.accounts()
    }
    
    override func createAccount(account: Account) {
        accountToCreate = account
    }
    
    override func currency() -> String {
        didAskCurrency = true
        return super.currency()
    }
}

class TestableAccountInteractor: AccountsInteractor {
    
}
