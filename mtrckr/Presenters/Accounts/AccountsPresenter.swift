//
//  AccountsPresenter.swift
//  mtrckr
//
//  Created by User on 6/28/17.
//

import UIKit

protocol AccountsPresenterProtocol {
    func showCreateAccount()
    func showEditAccount(with id: String)
    func accounts() -> [Account]
}

class AccountsPresenter: AccountsPresenterProtocol {
    func showCreateAccount() {
        
    }
    
    func showEditAccount(with id: String) {
        
    }
    
    func accounts() -> [Account] {
        return []
    }
}
