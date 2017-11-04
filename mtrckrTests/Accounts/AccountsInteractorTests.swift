//
//  AccountsInteractorTests.swift
//  mtrckrTests
//
//  Created by User on 7/5/17.
//

import UIKit
import Quick
import Nimble
import Realm
import RealmSwift
@testable import mtrckr

class AccountsInteractorTests: QuickSpec {
    
    var accountsInteractor: AccountsInteractor?
    var identifier = "AccountsInteractorTests"
    
    override func spec() {
        describe("AccountsInteractorTests") {
            
            var cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
            var dateOpened = Date()
            var realm: Realm?
            var account: Account?
            
            beforeEach {
                
                var config = Realm.Configuration()
                config.inMemoryIdentifier = self.identifier
                realm = try? Realm(configuration: config)
                try! realm?.write {
                    realm!.deleteAll()
                }
                
                self.accountsInteractor = AccountsInteractor(with: RealmAuthConfig())
                self.accountsInteractor?.realmContainer = MockRealmContainer(memoryIdentifier: self.identifier)
                self.accountsInteractor?.realmContainer?.setDefaultRealm(to: .offline)
                
                dateOpened = Date()
                cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
                account = Account(value:
                     ["id": "accnt1",
                      "name": "My Cash",
                      "type": cashAccountType,
                      "initialAmount": 10.0,
                      "currentAmount": 20.0,
                      "totalExpenses": 100.0,
                      "totalIncome": 30.0,
                      "color": "#AAAAAA",
                      "dateOpened": dateOpened ])
            }
            
            context("when asked to create an account", {
                context("reached limit of 20 accounts", {
                    beforeEach {
                        let r = self.accountsInteractor?.realmContainer?.userRealm
                        for i in 0..<20 {
                            account?.save(toRealm: r!)
                            account = Account(value:
                                ["id": "accnt-\(i)",
                                  "name": "My Cash",
                                  "type": cashAccountType,
                                  "initialAmount": 10.0,
                                  "currentAmount": 20.0,
                                  "totalExpenses": 100.0,
                                  "totalIncome": 30.0,
                                  "color": "#AAAAAA",
                                  "dateOpened": dateOpened ])
                        }
                    }
                    
                    it("throws an error", closure: {
                        expect { try self.accountsInteractor?.createAccount(account: account!) }.to(throwError())
                    })
                })
                
                context("accounts saved is less than 20", {
                    it("throws no error", closure: {
                        expect({ try self.accountsInteractor?.createAccount(account: account!) }).toNot(throwError())
                    })
                    
                    context("account is new", {
                        beforeEach {
                            try? self.accountsInteractor?.createAccount(account: account!)
                        }
                        
                        itBehavesLike("account can be found in database") { ["account": account!, "realm": realm!] }
                    })
                    
                    context("account id already exists", {
                        var newAccount: Account?
                        beforeEach {
                            try? self.accountsInteractor?.createAccount(account: account!)
                            newAccount = Account(value:
                                ["id": "accnt1",
                                 "name": "My Cashuuu",
                                 "type": cashAccountType,
                                 "initialAmount": 10.0,
                                 "currentAmount": 20.0,
                                 "totalExpenses": 100.0,
                                 "totalIncome": 30.0,
                                 "color": "#AAAAAA",
                                 "dateOpened": dateOpened ])
                            
                            newAccount?.name = "new name"
                            newAccount?.dateOpened = Date()
                            newAccount?.initialAmount = 0.23
                            try? self.accountsInteractor?.createAccount(account: newAccount!)
                        }
                        
                        itBehavesLike("account can be found in database") { ["account": newAccount!, "realm": realm!] }
                    })
                })
            })
            
            context("when asked to retrieve accounts", {
                it("calls Account.all", closure: {
                    let realm = self.accountsInteractor!.realmContainer!.userRealm!
                    let accounts = self.accountsInteractor?.accounts()
                    let dbAccounts = Account.all(in: realm)
                    expect(accounts?.count) == dbAccounts.count
                })
            })
            
            context("when asked to delete an account", {
                beforeEach {
                    account!.save(toRealm: realm!)
                    self.accountsInteractor?.deleteAccount(account: account!)
                    account = Account(value:
                         ["id": "accnt1",
                          "name": "My Cash",
                          "type": cashAccountType,
                          "initialAmount": 10.0,
                          "currentAmount": 20.0,
                          "totalExpenses": 100.0,
                          "totalIncome": 30.0,
                          "color": "#AAAAAA",
                          "dateOpened": dateOpened ])
                }
                itBehavesLike("account cannot be found in database") {
                    ["account": account!,
                     "realm": realm!]
                }
            })
            
            context("when asked to retrieve used currency", {
                it("calls container.currency", closure: {
                    _ = self.accountsInteractor?.currency()
                    expect((self.accountsInteractor?.realmContainer as? MockRealmContainer)?
                        .didCallCurrency) == true
                })
            })
        }
    }
}
