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
import Realm
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
            describe("initialize with values", {
                it("initializes and assign properties correctly", closure: {
                    let cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
                    let dateOpened = Date()

                    let account = Account(value: ["id": "accnt1",
                                                    "name": "My Cash",
                                                    "type": cashAccountType,
                                                    "initialAmount": 10.0,
                                                    "currentAmount": 20.0,
                                                    "totalExpenses": 100.0,
                                                    "totalIncome": 30.0,
                                                    "color": "#AAAAAA",
                                                    "dateOpened": dateOpened
                                                  ])

                    expect(account.id) == "accnt1"
                    expect(account.name) == "My Cash"
                    expect(account.type) == cashAccountType
                    expect(account.initialAmount) == 10.0
                    expect(account.currentAmount) == 20.0
                    expect(account.totalExpenses) == 100.00
                    expect(account.totalIncome) == 30.0
                    expect(account.color) == "#AAAAAA"
                    expect(account.dateOpened) == dateOpened
                })
            })
        }

        describe("CRUD operations") {

            var cashAccountType: AccountType!
            var dateOpened: Date!
            var user: User!
            var account: Account!

            beforeEach {
                let currency = Currency(id: "Curr1", isoCode: "USD", symbol: "$", state: "USA")
                cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
                user = User(id: "user0", name: "", email: "", image: "", currency: currency)
                dateOpened = Date()
                account = Account(value: ["id": "accnt1",
                                          "name": "My Cash",
                                          "type": cashAccountType,
                                          "initialAmount": 10.0,
                                          "currentAmount": 20.0,
                                          "totalExpenses": 100.0,
                                          "totalIncome": 30.0,
                                          "color": "#AAAAAA",
                                          "dateOpened": dateOpened])
            }

            describe("save()", {
                beforeEach {
                    account.save(toRealm: self.testRealm)
                }
                
                itBehavesLike("can be found in database") { ["account": account, "realm": self.testRealm] }
            })

            describe("update()", {
                context("update all values from json/key-value", {
                    it("updates values if object already exists", closure: {
                        account.save(toRealm: self.testRealm)

                        let accountFromDatabase = self.testRealm.objects(Account.self).last
                        let updatedAccount = Account(value: ["id": "accnt1",
                                                      "name": "My Bank Account",
                                                      "type": cashAccountType,
                                                      "initialAmount": 10000.0,
                                                      "currentAmount": 20000,
                                                      "totalExpenses": 0.0,
                                                      "totalIncome": 10000,
                                                      "color": "#BBBBBB",
                                                      "dateOpened": dateOpened])
                        accountFromDatabase!.update(to: updatedAccount, in: self.testRealm)

                        let accounts = Account.all(in: self.testRealm)
                        expect(accounts.count) == 1
                        expect(accounts[0].name) == "My Bank Account"
                        expect(accounts[0].type) == cashAccountType
                        expect(accounts[0].initialAmount) == 10000.0
                        expect(accounts[0].currentAmount) == 20000.0
                        expect(accounts[0].totalExpenses) == 0.0
                        expect(accounts[0].totalIncome) == 10000
                        expect(accounts[0].color) == "#BBBBBB"
                        expect(accounts[0].dateOpened) == dateOpened
                    })
                })
                context("user can only update name, type, initial amount, color and date opened", {

                    var bankAccountType: AccountType!
                    var accountFromDatabase: Account!

                    beforeEach {
                        account.save(toRealm: self.testRealm)

                        bankAccountType = AccountType(typeId: 2, name: "Bank Account", icon: "bank.jpg")
                        accountFromDatabase = self.testRealm.objects(Account.self).last
                        accountFromDatabase!.update(name: "My Bank Account", type: bankAccountType, initialAmount: 100.0,
                                                    color: "#CCCCCC", dateOpened: dateOpened, in: self.testRealm)
                    }

                    it("updates values if object already exists", closure: {
                        let accounts = Account.all(in: self.testRealm)
                        expect(accounts.count) == 1
                        expect(accounts[0].name) == "My Bank Account"
                        expect(accounts[0].type) == bankAccountType
                        expect(accounts[0].initialAmount) == 100.0
                        expect(accounts[0].color) == "#CCCCCC"
                        expect(accounts[0].dateOpened) == dateOpened
                    })

                    context("updating initial amount", {
                        it("updates current amount", closure: {
                            let fetchedAccount = Account.with(key: "accnt1", inRealm: self.testRealm)
                            expect(fetchedAccount!.currentAmount) == 110
                        })
                    })
                })

                context("account to update does not exist in realm") {
                    it("doesn't have any effect", closure: {
                        account.save(toRealm: self.testRealm)

                        let anotherAccount = Account(value: ["id": "accnt2",
                                                             "name": "My Bank Account",
                                                             "type": cashAccountType,
                                                             "initialAmount": 10000.0,
                                                             "currentAmount": 20000,
                                                             "totalExpenses": 0.0,
                                                             "totalIncome": 10000,
                                                             "color": "#BBBBBB",
                                                             "dateOpened": dateOpened])

                        anotherAccount.update(name: "Some account",
                                              type: cashAccountType,
                                              initialAmount: 1.0,
                                              color: "#aaaaaa",
                                              dateOpened: dateOpened, in: self.testRealm)

                        let accounts = Account.all(in: self.testRealm)
                        expect(accounts.count) == 1
                        expect(accounts[0].name) == "My Cash"
                        expect(accounts[0].type) == cashAccountType
                        expect(accounts[0].initialAmount) == 10
                        expect(accounts[0].currentAmount) == 20
                        expect(accounts[0].totalExpenses) == 100
                        expect(accounts[0].totalIncome) == 30
                        expect(accounts[0].color) == "#AAAAAA"
                        expect(accounts[0].dateOpened) == dateOpened
                    })
                }
            })

            describe("all() of user", {
                it("returns all Accounts of given user sorted by name", closure: {
                    self.createAccounts(n: 3, for: user)
                    let Accounts = Account.all(in: self.testRealm)
                    expect(Accounts.count) == 3
                    expect(Accounts[0].id) == "accnt0"
                    expect(Accounts[1].id) == "accnt1"
                    expect(Accounts[2].id) == "accnt2"
                })
            })

            describe("delete()", {
                beforeEach {
                    self.createAccounts(n: 3, for: user)
                    let firstAccount = Account.with(key: "accnt0", inRealm: self.testRealm)
                    firstAccount?.delete(in: self.testRealm)
                }

                it("deletes account from database", closure: {
                    let accounts = Account.all(in: self.testRealm)
                    expect(accounts.count) == 2
                    expect(accounts[0].id) == "accnt1"
                    expect(accounts[1].id) == "accnt2"
                })

                it("deletes transactions under deleted account", closure: {
                    let category = mtrckr.Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg", color: "")
                    let transactions = Transaction.all(in: self.testRealm, underCategory: category)
                    expect(transactions.count) == 2
                    expect(transactions[0].name) == "trans 2"
                    expect(transactions[1].name) == "trans 1"
                })
            })
        }
    }

    func createAccounts(n: Int, for user: User) {
        let cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
        let category = mtrckr.Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg", color: "")
        for i in 0..<n {
            let acc = Account(value: ["id": "accnt\(i)",
                            "name": "Account \(i)",
                            "type": cashAccountType,
                            "initialAmount": 0.0,
                            "currentAmount": 0.0,
                            "totalExpenses": 0.0,
                            "totalIncome": 0.0,
                            "color": "",
                            "dateOpened": Date()])
            acc.save(toRealm: self.testRealm)
            Transaction(type: .expense, name: "trans \(i)", image: nil,
                        description: nil, amount: 100, category: category,
                        from: acc, to: acc, date: Date()).save(toRealm: self.testRealm)
        }
    }
}

class SharedAccountsBehavior: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("can be found in database") { (context: @escaping SharedExampleContext) in
            var account: Account?
            var realm: Realm?
            
            beforeEach {
                account = context()["account"] as? Account
                realm = context()["realm"] as? Realm
            }
            
            it("saves object to database correctly", closure: {
                let accountFromDatabase = realm?.objects(Account.self).last
                expect(accountFromDatabase?.id) == account?.id
                expect(accountFromDatabase?.name) == account?.name
                expect(accountFromDatabase?.type) == account?.type
                expect(accountFromDatabase?.initialAmount) == account?.initialAmount
                expect(accountFromDatabase?.currentAmount) == account?.currentAmount
                expect(accountFromDatabase?.totalExpenses) == account?.totalExpenses
                expect(accountFromDatabase?.totalIncome) == account?.totalIncome
                expect(accountFromDatabase?.color) == account?.color
                expect(accountFromDatabase?.dateOpened) == account?.dateOpened
            })
        }
        
        sharedExamples("cannot be found in database") { (context: @escaping SharedExampleContext) in
            var account: Account?
            var realm: Realm?
            
            beforeEach {
                account = context()["account"] as? Account
                realm = context()["realm"] as? Realm
            }
            
            it("must be nil", closure: {
                let accountFromDatabase = Account.with(key: account!.id, inRealm: realm!)
                expect(accountFromDatabase).to(beNil())
            })
        }
    }
}
