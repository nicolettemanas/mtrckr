//
//  TransactionTests.swift
//  mtrckr
//
//  Created by User on 4/10/17.
//
//

import XCTest
import Quick
import Nimble
import RealmSwift
@testable import mtrckr

class TransactionTests: QuickSpec {
    
    var testRealm: Realm!
    
    override func spec() {
        
        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "TransactionTests Database"
        }
        
        beforeEach {
            self.testRealm = try! Realm()
            try! self.testRealm.write {
                self.testRealm.deleteAll()
            }
        }
        
        describe("Model Transaction") {
            var transaction: Transaction!
            var transDate: Date!
            var account: Account!
            var user: User!
            var category: mtrckr.Category!
            var currency: Currency!
            var cashAccountType: AccountType!
            
            beforeEach {
                currency = Currency(isoCode: "USD", symbol: "`$", state: "USA")
                user = User(id: "user1", name: "", email: "", image: "", currency: currency)
                category = Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg")
                cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
                account = Account(value: ["id": "accnt1",
                                          "name": "My Cash",
                                          "type": cashAccountType,
                                          "initialAmount": 10.0,
                                          "currentAmount": 20.0,
                                          "totalExpenses": 100.0,
                                          "totalIncome": 30.0,
                                          "color": "#AAAAAA",
                                          "dateOpened": Date(),
                                          "user": user ])
                transDate = Date()
            }
            
            context("initialize with values dueDate and bill", {
                
                beforeEach {
                    transaction = Transaction(type: .expense, name: "Breakfast", image: nil, description: "Subway: Spicy Italian", amount: 99.0,
                                              category: category, from: account, to: account, date: transDate)
                }
                
                it("initializes and assign properties correctly", closure: {
                    expect(transaction.type) == TransactionType.expense.rawValue
                    expect(transaction.name) == "Breakfast"
                    expect(transaction.image).to(beNil())
                    expect(transaction.desc) == "Subway: Spicy Italian"
                    expect(transaction.amount) == 99
                    expect(transaction.category) == category
                    expect(transaction.fromAccount) == account
                    expect(transaction.toAccount) == account
                    expect(transaction.transactionDate) == transDate
                })
            })
        }
        
        describe("CRUD operations") {
            
            var transaction: Transaction!
            var transDate: Date!
            var account: Account!
            var user: User!
            var category: mtrckr.Category!
            var currency: Currency!
            var cashAccountType: AccountType!
            
            beforeEach {
                currency = Currency(isoCode: "USD", symbol: "`$", state: "USA")
                user = User(id: "user1", name: "", email: "", image: "", currency: currency)
                category = Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg")
                cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
                account = Account(value: ["id": "accnt1",
                                          "name": "My Cash",
                                          "type": cashAccountType,
                                          "initialAmount": 0.0,
                                          "currentAmount": 0.0,
                                          "totalExpenses": 0.0,
                                          "totalIncome": 0.0,
                                          "color": "#AAAAAA",
                                          "dateOpened": Date(),
                                          "user": user ])
                transDate = Date()
                
                currency.save(toRealm: self.testRealm)
                cashAccountType.save(toRealm: self.testRealm)
                account.save(toRealm: self.testRealm)
                category.save(toRealm: self.testRealm)
                user.save(toRealm: self.testRealm)
            }
            
            describe("save()", {
                
                var transactionSaved: Transaction!
                
                it("saves object to database correctly", closure: {
                    transaction = Transaction(type: .expense, name: "Breakfast", image: nil, description: "Subway: Spicy Italian", amount: 99.0,
                                              category: category, from: account, to: account, date: transDate)
                    transaction.save(toRealm: self.testRealm)
                    
                    transactionSaved = self.testRealm.objects(Transaction.self).last!
                    expect(transactionSaved.type) == TransactionType.expense.rawValue
                    expect(transactionSaved.name) == "Breakfast"
                    expect(transactionSaved.image).to(beNil())
                    expect(transactionSaved.desc) == "Subway: Spicy Italian"
                    expect(transactionSaved.amount) == 99
                    expect(transactionSaved.category) == category
                    expect(transactionSaved.fromAccount) == account
                    expect(transactionSaved.toAccount) == account
                    expect(transactionSaved.transactionDate) == transDate
                })
                
                it("should reflect under account", closure: { 
                    transaction = Transaction(type: .expense, name: "Breakfast", image: nil, description: "Subway: Spicy Italian", amount: 99.0,
                                              category: category, from: account, to: account, date: transDate)
                    transaction.save(toRealm: self.testRealm)
                    let accountAffected = Account.with(key: "accnt1", inRealm: self.testRealm)
                    expect(accountAffected?.transactionsFromSelf.count) == 1
                    expect(accountAffected?.transactionsToSelf.count) == 1
                    expect(accountAffected?.transactionsFromSelf[0]) == transaction
                    expect(accountAffected?.transactionsToSelf[0]) == transaction
                })
                
                context("transaction is of type expense", {
                    it("should add to account's total expenses and subtract to current amount", closure: {
                        transaction = Transaction(type: .expense, name: "Breakfast", image: nil, description: "Subway: Spicy Italian", amount: 99.0,
                                                  category: category, from: account, to: account, date: transDate)
                        transaction.save(toRealm: self.testRealm)
                        let accountAffected = Account.with(key: "accnt1", inRealm: self.testRealm)
                        expect(accountAffected?.currentAmount) == -99
                        expect(accountAffected?.totalExpenses) == 99
                        expect(accountAffected?.totalIncome) == 0
                    })
                })
                
                context("transaction is of type income", { 
                    it("should add to account's total income and add to current amount", closure: {
                        let newCategory = Category(id: "cat1", type: .income, name: "Income", icon: "income.jpg")
                        transaction = Transaction(type: .income, name: "Salary", image: nil, description: "January Salary", amount: 10000,
                                                  category: newCategory, from: account, to: account, date: transDate)
                        transaction.save(toRealm: self.testRealm)
                        let accountAffected = Account.with(key: "accnt1", inRealm: self.testRealm)
                        expect(accountAffected?.currentAmount) == 10000
                        expect(accountAffected?.totalExpenses) == 0
                        expect(accountAffected?.totalIncome) == 10000
                    })
                })
                
                context("adding a transfer transaction", { 
                    it("should subtract from fromAccount's current amount and add to toAccount's current amount", closure: {
                        
                        var toAccount = Account(value: ["id": "accnt2",
                                                  "name": "My Cash",
                                                  "type": cashAccountType,
                                                  "initialAmount": 0.0,
                                                  "currentAmount": 0.0,
                                                  "totalExpenses": 0.0,
                                                  "totalIncome": 0.0,
                                                  "color": "#AAAAAA",
                                                  "dateOpened": Date(),
                                                  "user": user ])
                        toAccount.save(toRealm: self.testRealm)
                        
                        transaction = Transaction(type: .transfer, name: "Allowance", image: nil, description: "Cash allowance", amount: 500,
                                                  category: nil, from: account, to: toAccount, date: transDate)
                        transaction.save(toRealm: self.testRealm)
                        
                        let fromAccount = Account.with(key: "accnt1", inRealm: self.testRealm)
                        toAccount = Account.with(key: "accnt2", inRealm: self.testRealm)!
                        
                        expect(fromAccount?.currentAmount) == -500
                        expect(toAccount.currentAmount) == 500
                    })
                })
            })
            
            describe("update()", {
                
                var transactionSaved: Transaction!
                var newAccount: Account!
                var newCategory: mtrckr.Category!
                var transDate: Date!
                
                beforeEach {
                    newAccount = Account(value: ["id": "accnt2",
                                                     "name": "My Cash",
                                                     "type": cashAccountType,
                                                     "initialAmount": 0.0,
                                                     "currentAmount": 0.0,
                                                     "totalExpenses": 0.0,
                                                     "totalIncome": 0.0,
                                                     "color": "#AAAAAA",
                                                     "dateOpened": Date(),
                                                     "user": user ])
                    newCategory = Category(id: "cat1", type: .income, name: "Income", icon: "income.jpg")
                    transDate = Date()
                }
                
                describe("updating existing transaction", {
                    it("updates values if object already exists", closure: {
                        transactionSaved = Transaction(type: .expense, name: "Breakfast", image: nil, description: "Subway: Spicy Italian", amount: 99.0, category: category, from: account, to: account, date: transDate)
                        transactionSaved.save(toRealm: self.testRealm)
                        
                        transactionSaved.update(type: .income, name: "Bonus", image: "/picture.jpg", description: "My Christmas Bonus", amount: 10000, category: newCategory, from: newAccount, to: newAccount, date: transDate, inRealm: self.testRealm)
                        
                        let transactionUpdated = self.testRealm.objects(Transaction.self).last!
                        expect(transactionUpdated.type) == TransactionType.income.rawValue
                        expect(transactionUpdated.name) == "Bonus"
                        expect(transactionUpdated.image) == "/picture.jpg"
                        expect(transactionUpdated.desc) == "My Christmas Bonus"
                        expect(transactionUpdated.amount) == 10000
                        expect(transactionUpdated.category) == newCategory
                        expect(transactionUpdated.fromAccount) == newAccount
                        expect(transactionUpdated.toAccount) == newAccount
                        expect(transactionUpdated.transactionDate) == transDate
                    })
                    
                    describe("update: change of account", {
                        it("should reset previous account and update new account", closure: { 
                            transactionSaved = Transaction(type: .expense, name: "Breakfast", image: nil, description: "Subway: Spicy Italian", amount: 99.0, category: category, from: account, to: account, date: transDate)
                            transactionSaved.save(toRealm: self.testRealm)
                            
                            transactionSaved.update(type: .expense, name: "Breakfast", image: nil, description: "Subway: Spicy Italian", amount: 99.0, category: category, from: newAccount, to: newAccount, date: transDate, inRealm: self.testRealm)
                            
                            let prevAccnt = Account.with(key: "accnt1", inRealm: self.testRealm)
                            let newAccnt = Account.with(key: "accnt2", inRealm: self.testRealm)
                            
                            expect(prevAccnt?.totalExpenses) == 0
                            expect(prevAccnt?.totalIncome) == 0
                            expect(prevAccnt?.currentAmount) == 0
                            
                            expect(newAccnt?.totalExpenses) == 99
                            expect(newAccnt?.totalIncome) == 0
                            expect(newAccnt?.currentAmount) == -99
                        })
                    })
                    
                    describe("update: change of type", { 
                        context("update is a change of type expense to income", {
                            it("should update account's current amount, subtract to total expenses and add to total income", closure: {
                                transactionSaved = Transaction(type: .expense, name: "Breakfast", image: nil, description: "Subway: Spicy Italian", amount: 99.0, category: category, from: account, to: account, date: transDate)
                                transactionSaved.save(toRealm: self.testRealm)
                                
                                transactionSaved.update(type: .income, name: "Salary", image: nil, description: "January Salary", amount: 10000,
                                                        category: newCategory, from: account, to: account, date: transDate, inRealm: self.testRealm)
                                
                                let accountAffected = Account.with(key: account.id, inRealm: self.testRealm)
                                expect(accountAffected?.currentAmount) == 10000
                                expect(accountAffected?.totalIncome) == 10000
                                expect(accountAffected?.totalExpenses) == 0
                                expect(accountAffected?.transactionsToSelf.count) == 1
                                expect(accountAffected?.transactionsFromSelf.count) == 1
                            })
                        })
                        
                        context("update is a change of type income to expense", {
                            it("should update account's current amount, add to total expenses and subtract to total income", closure: {
                                
                            })
                        })
                        
                        context("update is a change of type from income/expense to transfer", {
                            it("should update account's current ammount, add expense and reset income", closure: {
                                
                            })
                        })
                        
                        context("update is a change of type from transfer to income", {
                            it("should update account's current ammount, reset expense and add to income", closure: {
                                
                            })
                        })
                    })
                    
                })
            })
            
            describe("all() of account", {
                it("returns all Transactions of given account sorted by transactionDate", closure: {
                    
                })
            })
            
            describe("all() of category", { 
                it("returns all Transactions of given category sorted by transactionDate", closure: {
                    
                })
            })
            
            describe("delete()", {
                
                var firstBillEntry: BillEntry!
                var entryId: String!
                
                beforeEach {
                    
                }
                
                it("deletes entry from database", closure: {
                    
                })
                
                it("should be deleted from the account it belongs to", closure: {
                    
                })
                
                context("deleted transaction is an expense", { 
                    it("its amount should be re-added back to account's total amount and subtracted to account's total expenses", closure: { 
                        
                    })
                    
                    context("deleted transaction has associated bill", {
                        it("bill entry should be marked as unpaid") {
                            
                        }
                    })
                })
                
                context("deleted transaction is an income", { 
                    it("its amount should be subtracted from account's total amount and subtracted to account's total income", closure: { 
                        
                    })
                })
                
                context("deleted transaction is a transfer", { 
                    it("amount should be added to FROM ACCOUNT's total amount and subtracted to TO ACCOUNT's account's total amount", closure: { 
                        
                    })
                })
            })
        }
    }
}
