//
//  MockAccountsPresenter.swift
//  mtrckrTests
//
//  Created by User on 6/28/17.
//

import UIKit
import Realm
import RealmSwift
@testable import mtrckr

class MockAccountsPresenter: AccountsPresenter {
    
    var didDelete = false
    var deleteAccountId = ""
    
    var didCreate = false
    var createWithAccountId: String?
    
    override func deleteAccount(account: Account) {
        didDelete = true
        deleteAccountId = account.id
    }
    
    override func createAccount(withId id: String?, name: String, type: AccountType,
                                initBalance: Double, dateOpened: Date, color: UIColor) {
        didCreate = true
        createWithAccountId = id
    }
}
