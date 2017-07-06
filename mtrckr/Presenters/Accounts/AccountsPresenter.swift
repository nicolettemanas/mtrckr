//
//  AccountsPresenter.swift
//  mtrckr
//
//  Created by User on 6/28/17.
//

import UIKit
import RealmSwift
import UIColor_Hex_Swift

protocol AccountsPresenterProtocol {
    var interactor: AccountsInteractorProtocol? { get set }
    
    init(interactor: AccountsInteractorProtocol?)
    
    func accounts() -> Results<Account>?
    func currency() -> String
    func deleteAccount(account: Account)
    func createAccount(withId: String?, name: String, type: AccountType,
                       initBalance: Double, dateOpened: Date,
                       color: UIColor) throws
}

class AccountsPresenter: AccountsPresenterProtocol {
    var interactor: AccountsInteractorProtocol?
    
    required init(interactor ai: AccountsInteractorProtocol?) {
        interactor = ai
    }
    
    func deleteAccount(account: Account) {
        interactor?.deleteAccount(account: account)
    }
    
    func accounts() -> Results<Account>? {
        guard let res = interactor?.accounts() else {
            return nil
        }
        
        return res
    }
    
    func createAccount(withId id: String?, name: String, type: AccountType,
                       initBalance: Double, dateOpened: Date,
                       color: UIColor) throws {
        
        let att: [String: Any] = ["id": id ?? "accnt-\(UUID().uuidString)",
                                    "name": name,
                                    "type": type,
                                    "initialAmount": initBalance,
                                    "currentAmount": initBalance,
                                    "totalExpenses": 0.0,
                                    "totalIncome": 0.0,
                                    "color": color.hexString(),
                                    "dateOpened": dateOpened]
        let acc: Account = Account(value: att)
        try interactor?.createAccount(account: acc)
    }
    
    func currency() -> String {
        return interactor?.currency() ?? "₱"
    }
}
