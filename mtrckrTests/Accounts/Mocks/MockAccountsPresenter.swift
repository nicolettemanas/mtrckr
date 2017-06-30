//
//  MockAccountsPresenter.swift
//  mtrckrTests
//
//  Created by User on 6/28/17.
//

import UIKit
@testable import mtrckr

class MockAccountsPresenter: AccountsPresenterProtocol {
    
    var didShowCreateAccount = false
    var didShowEditAccount = false
    var editAccountId: String?
    
    func showCreateAccount() {
        didShowCreateAccount = true
    }
    
    func showEditAccount(with id: String) {
        didShowEditAccount = true
        editAccountId = id
    }
    
    func accounts() -> [Account] {
        return []
    }
}
