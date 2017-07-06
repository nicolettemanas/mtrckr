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

/// The event handler for `Account`s Tableview controller
class AccountsPresenter: AccountsPresenterProtocol {
    
    /// The interactor responsible for `Account` modifications
    var interactor: AccountsInteractorProtocol?
    
    // MARK: - Initializers
    
    /// Creates an `AccountsPresenter` with the given interactor
    ///
    /// - Parameter ai: The interactor to use in `Account` modifications
    required init(interactor ai: AccountsInteractorProtocol?) {
        interactor = ai
    }
    
    /// MARK: - Event handlers
    
    /// Passes the `Account` to delete to the interactor
    ///
    /// - Parameter account: The `Account` to delete
    func deleteAccount(account: Account) {
        interactor?.deleteAccount(account: account)
    }
    
    /// Asks for the list of `Account`s from the interactor
    ///
    /// - Returns: <#return value description#>
    func accounts() -> Results<Account>? {
        guard let res = interactor?.accounts() else {
            return nil
        }
        
        return res
    }
    
    /// Makes an untracked `Account` with the given values and passes it to
    /// the interactor to save or update
    ///
    /// - Parameters:
    ///   - id: The ID of the `Account` to be created
    ///   - name: The name of the `Account` to be created
    ///   - type: The type of the `Account` to be created
    ///   - initBalance: The initial value of the `Account` to be created
    ///   - dateOpened: The date the `Account` was opened
    ///   - color: The color of the `Account` to be created
    /// - Throws: Throws an error if succeeded the limit of 20 accounts per user
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
    
    /// Asks the interactor for the currency symbol used
    /// by the logged in user
    ///
    /// - Returns: The currency used. Default value is `₱`
    func currency() -> String {
        return interactor?.currency() ?? "₱"
    }
}
