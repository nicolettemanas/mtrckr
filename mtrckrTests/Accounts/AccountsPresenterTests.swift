//
//  AccountsPresenterTests.swift
//  mtrckrTests
//
//  Created by User on 7/5/17.
//

import UIKit
import Realm
import RealmSwift
import Quick
import Nimble
@testable import mtrckr

class AccountsPresenterTests: QuickSpec {
    
    var accountsPresenter: AccountsPresenter?
    var mockAccountsInteractor: MockAccountsInteractor?
    
    var identifier = "AccountsPresenterTests"
    
    override func spec() {
        beforeEach {
            self.mockAccountsInteractor = MockAccountsInteractor(with: RealmAuthConfig())
            self.mockAccountsInteractor?.realmContainer = MockRealmContainer(memoryIdentifier: self.identifier)
            self.mockAccountsInteractor?.realmContainer?.setDefaultRealm(to: .offline)
            
            self.accountsPresenter = AccountsPresenter(interactor: self.mockAccountsInteractor!)
        }
        
        describe("AccountsPresenter") {
            
            let cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
            let dateOpened = Date()
            var account: Account?
            
            beforeEach {
                account = Account(value: ["id": "accnt1",
                                              "name": "My Cash",
                                              "type": cashAccountType,
                                              "initialAmount": 10.0,
                                              "currentAmount": 20.0,
                                              "totalExpenses": 100.0,
                                              "totalIncome": 30.0,
                                              "color": "#AAAAAA",
                                              "dateOpened": dateOpened
                    ])
            }
            
            context("asked to delete an account", {
                it("forwards account to delete to interactor", closure: {
                    self.accountsPresenter?.deleteAccount(account: account!)
                    expect(self.mockAccountsInteractor?.accountToDelete) == account
                })
            })
            
            context("asked to retrieve accounts", {
                it("asks interactor to retrieve accounts", closure: {
                    _ = self.accountsPresenter?.accounts()
                    expect(self.mockAccountsInteractor?.didRetrieveAccounts) == true
                })
            })
            
            context("asked to create an account given property values", {
                it("passes generated account model to interactor to create to database", closure: {
                    try? self.accountsPresenter?.createAccount(withId: "accnt2", name: "account name",
                                                          type: cashAccountType, initBalance: 10,
                                                          dateOpened: dateOpened, color: .red)
                    let a = self.mockAccountsInteractor?.accountToCreate
                    expect(a?.id) == "accnt2"
                    expect(a?.name) == "account name"
                    expect(a?.initialAmount) == 10
                    expect(a?.dateOpened) == dateOpened
                    expect(a?.color) == "#FF0000FF"
                })
            })
            
            context("asked for the currency used", {
                it("asks for the currency to the interactor ", closure: {
                    _ = self.accountsPresenter?.currency()
                    expect(self.mockAccountsInteractor?.didAskCurrency) == true
                })
                
                context("there is no currency retrieved", {
                    it("returns '₱' as default", closure: {
                        let p = self.accountsPresenter?.currency()
                        expect(p) == "₱"
                    })
                })
            })
        }
    }
}
