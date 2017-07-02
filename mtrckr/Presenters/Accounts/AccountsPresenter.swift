//
//  AccountsPresenter.swift
//  mtrckr
//
//  Created by User on 6/28/17.
//

import UIKit
import UIColor_Hex_Swift

protocol AccountsPresenterOutput: class {
    func updateAccounts()
}

protocol AccountsPresenterProtocol {
    var interactor: AccountsInteractorProtocol? { get set }
    weak var output: AccountsPresenterOutput? { get set }
    
    init(interactor: AccountsInteractorProtocol?, output ao: AccountsPresenterOutput?)
    
    func showEditAccount(with id: String)
    func accounts() -> [Account]
    func currency() -> String
    func createAccount(withId: String?, name: String, type: AccountType,
                       initBalance: Double, dateOpened: Date,
                       color: UIColor)
}

class AccountsPresenter: AccountsInteractorOutput, AccountsPresenterProtocol {
    weak var output: AccountsPresenterOutput?
    var interactor: AccountsInteractorProtocol?
    
    required init(interactor ai: AccountsInteractorProtocol?, output ao: AccountsPresenterOutput?) {
        interactor = ai
        output = ao
    }
    
    func showEditAccount(with id: String) {
        
    }
    
    func accounts() -> [Account] {
        guard let res = interactor?.accounts() else {
            return []
        }
        
        return Array(res)
    }
    
    func createAccount(withId id: String?, name: String, type: AccountType,
                       initBalance: Double, dateOpened: Date,
                       color: UIColor) {
        
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
        interactor?.createAccount(account: acc)
    }
    
    func currency() -> String {
        return interactor?.currency() ?? "₱"
    }
    
    // MARK: - AccountsInteractorOutput methods
    func didUpdateAccounts() {
        output?.updateAccounts()
    }
}
