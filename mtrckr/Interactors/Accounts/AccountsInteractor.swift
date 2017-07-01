//
//  AccountsInteractor.swift
//  mtrckr
//
//  Created by User on 6/30/17.
//

import UIKit
import Realm
import RealmSwift

protocol AccountsInteractorOutput: class {
    func didUpdateAccounts()
}

protocol AccountsInteractorProtocol {
    func currency() -> String
    func createAccount(account: Account)
    func accounts() -> Results<Account>
    weak var output: AccountsInteractorOutput? { get set }
}
class AccountsInteractor: RealmHolder, AccountsInteractorProtocol {
    var realm: Realm?
    var notificationToken: NotificationToken?
    weak var output: AccountsInteractorOutput?
    
    override init(with config: AuthConfig) {
        super.init(with: config)
        realm = realmContainer?.userRealm
        notificationToken = realm?.addNotificationBlock({ (_, _) in
            self.output?.didUpdateAccounts()
        })
    }
    
    func createAccount(account: Account) {
        account.save(toRealm: realm!)
    }
    
    func accounts() -> Results<Account> {
        return Account.all(in: realm!)
    }
    
    func currency() -> String {
        return realmContainer?.currency() ?? "₱"
    }
}
