//
//  AccountTests.swift
//  mtrckr
//
//  Created by User on 4/6/17.
//
//

import XCTest
import Quick
import Nimble
import RealmSwift
@testable import mtrckr

class AccountTests: QuickSpec {
    
    var testRealm: Realm!
    
    override func spec() {
        
        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "AccountTests Database"
        }
        
        beforeEach {
            self.testRealm = try! Realm()
            try! self.testRealm.write {
                self.testRealm.deleteAll()
            }
        }
        
        describe("Model Account") {
//            describe("initialize with values", {
//                it("initializes and assign properties correctly", closure: {
//                    let cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
//                    let user = User(value: ["id": "user1"])
//                    let dateOpened = Date()
//
//                    let account = Account(value: [  "id": "accnt1",
//                                                    "name": "My Cash",
//                                                    "type": cashAccountType,
//                                                    "initialAmount": 10.0,
//                                                    "currentAmount": 20.0,
//                                                    "totalExpenses": 100.0,
//                                                    "totalIncome": 30.0,
//                                                    "color": "#AAAAAA",
//                                                    "dateOpened": dateOpened,
//                                                    "user": user
//                                                  ] )
//                    
//                    expect(account.id) == "accnt1"
//                    expect(account.name) == "My Cash"
//                    expect(account.type) == cashAccountType
//                    expect(account.initialAmount) == 10.0
//                    expect(account.currentAmount) == 20.0
//                    expect(account.totalExpenses) == 100.00
//                    expect(account.totalIncome) == 30.0
//                    expect(account.color) == "#AAAAAA"
//                    expect(account.dateOpened) == dateOpened
//                    expect(account.user) == user
//                })
//            })
        }
        
//        describe("CRUD operations") {
//            describe("save()", {
//                it("saves object to database correctly", closure: {
//                    let Account = Account(typeId: 1, name: "Cash", icon: "")
//                    Account.save(toRealm: self.testRealm)
//                    
//                    let AccountFromDatabase = self.testRealm.objects(Account.self).last
//                    expect(AccountFromDatabase?.typeId) == 1
//                    expect(AccountFromDatabase?.name) == "Cash"
//                    expect(AccountFromDatabase?.icon) == ""
//                })
//            })
//            
//            describe("update()", {
//                it("updates values if object already exists", closure: {
//                    let Account = Account(typeId: 1, name: "Cash", icon: "")
//                    Account.save(toRealm: self.testRealm)
//                    
//                    let AccountFromDatabase = self.testRealm.objects(Account.self).last
//                    let updatedAccount = Account(typeId: 1, name: "Bank", icon: "default.png")
//                    AccountFromDatabase?.update(to: updatedAccount, in: self.testRealm)
//                    
//                    let Accounts = Account.all(in: self.testRealm)
//                    expect(Accounts.count) == 1
//                    expect(Accounts[0].name) == "Bank"
//                    expect(Accounts[0].icon) == "default.png"
//                    
//                })
//            })
//            
//            describe("all()", {
//                it("returns all Accounts sorted by name", closure: {
//                    self.createAccounts(n: 3)
//                    let Accounts = Account.all(in: self.testRealm)
//                    expect(Accounts.count) == 3
//                    expect(Accounts[0].name) == "Account 0"
//                    expect(Accounts[1].name) == "Account 1"
//                    expect(Accounts[2].name) == "Account 2"
//                })
//            })
//            
//            describe("delete()", {
//                it("deletes object from database", closure: {
//                    self.createAccounts(n: 3)
//                    let firstAccount = Account.with(key: 0, inRealm: self.testRealm)
//                    firstAccount?.delete(in: self.testRealm)
//                    
//                    let Accounts = Account.all(in: self.testRealm)
//                    expect(Accounts.count) == 2
//                    expect(Accounts[0].name) == "Account 1"
//                    expect(Accounts[1].name) == "Account 2"
//                })
//            })
//        }
    }
    
//    func createAccounts(n: Int) {
//        for i in 0..<n {
//            Account(typeId: i, name: "Account \(i)", icon: "").save(toRealm: testRealm)
//        }
//    }
    
}
