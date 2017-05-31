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
                currency = Currency(id: "Curr1", isoCode: "USD", symbol: "`$", state: "USA")
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
                                          "dateOpened": Date()])
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
                currency = Currency(id: "Curr1", isoCode: "USD", symbol: "`$", state: "USA")
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
                                          "dateOpened": Date()])
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
                                                  "dateOpened": Date()])
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
                                                     "dateOpened": Date()])
                    newCategory = Category(id: "cat1", type: .income, name: "Income", icon: "income.jpg")
                    transDate = Date()
                }

                describe("updating existing transaction", {
                    it("updates values if object already exists", closure: {
                        transactionSaved = Transaction(type: .expense, name: "Breakfast", image: nil,
                                                       description: "Subway: Spicy Italian", amount: 99.0, category: category,
                                                       from: account, to: account, date: transDate)
                        transactionSaved.save(toRealm: self.testRealm)

                        transactionSaved.update(type: .income, name: "Bonus", image: "/picture.jpg",
                                                description: "My Christmas Bonus", amount: 10000, category: newCategory,
                                                from: newAccount, to: newAccount, date: transDate, inRealm: self.testRealm)

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
                            transactionSaved = Transaction(type: .expense, name: "Breakfast", image: nil,
                                                           description: "Subway: Spicy Italian", amount: 99.0, category: category,
                                                           from: account, to: account, date: transDate)
                            transactionSaved.save(toRealm: self.testRealm)

                            transactionSaved.update(type: .expense, name: "Breakfast", image: nil,
                                                    description: "Subway: Spicy Italian", amount: 99.0, category: category,
                                                    from: newAccount, to: newAccount, date: transDate, inRealm: self.testRealm)

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
                                transactionSaved = Transaction(type: .expense, name: "Breakfast", image: nil, description: "Subway: Spicy Italian",
                                                               amount: 99.0, category: category,
                                                               from: account, to: account, date: transDate)
                                transactionSaved.save(toRealm: self.testRealm)

                                transactionSaved.update(type: .income, name: "Salary", image: nil,
                                                        description: "January Salary", amount: 10000, category: newCategory,
                                                        from: account, to: account, date: transDate, inRealm: self.testRealm)

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
                                transactionSaved = Transaction(type: .income, name: "Salary", image: nil,
                                                               description: "January Salary", amount: 10000, category: newCategory,
                                                               from: account, to: account, date: transDate)
                                transactionSaved.save(toRealm: self.testRealm)

                                transactionSaved.update(type: .expense, name: "Breakfast", image: nil,
                                                        description: "Subway: Spicy Italian", amount: 99.0, category: category,
                                                        from: account, to: account, date: transDate, inRealm: self.testRealm)

                                let accountAffected = Account.with(key: account.id, inRealm: self.testRealm)
                                expect(accountAffected?.currentAmount) == -99
                                expect(accountAffected?.totalIncome) == 0
                                expect(accountAffected?.totalExpenses) == 99
                                expect(accountAffected?.transactionsToSelf.count) == 1
                                expect(accountAffected?.transactionsFromSelf.count) == 1
                            })
                        })

                        context("update is a change of type from income/expense to transfer", {
                            it("should update account's current ammount, add expense and reset income", closure: {
                                transactionSaved = Transaction(type: .income, name: "Salary", image: nil,
                                                               description: "January Salary", amount: 10000, category: newCategory,
                                                               from: account, to: account, date: transDate)
                                transactionSaved.save(toRealm: self.testRealm)

                                transactionSaved.update(type: .transfer, name: "Allowance", image: nil,
                                                        description: "Cash allowance", amount: 500, category: nil,
                                                        from: account, to: newAccount, date: transDate, inRealm: self.testRealm)

                                let fAccount = Account.with(key: account.id, inRealm: self.testRealm)
                                expect(fAccount?.currentAmount) == -500
                                expect(fAccount?.totalIncome) == 0
                                expect(fAccount?.totalExpenses) == 0
                                expect(fAccount?.transactionsToSelf.count) == 0
                                expect(fAccount?.transactionsFromSelf.count) == 1

                                let tAccount = Account.with(key: newAccount.id, inRealm: self.testRealm)
                                expect(tAccount?.currentAmount) == 500
                                expect(tAccount?.totalIncome) == 0
                                expect(tAccount?.totalExpenses) == 0
                                expect(tAccount?.transactionsToSelf.count) == 1
                                expect(tAccount?.transactionsFromSelf.count) == 0
                            })
                        })

                        context("update is a change of type from transfer to income/expense", {
                            it("should update account's current ammount, reset expense and add to income", closure: {
                                transactionSaved = Transaction(type: .transfer, name: "Allowance", image: nil,
                                                               description: "Cash allowance", amount: 500, category: nil,
                                                               from: account, to: newAccount, date: transDate)
                                transactionSaved.save(toRealm: self.testRealm)

                                transactionSaved.update(type: .income, name: "Salary", image: nil,
                                                        description: "January Salary", amount: 10000,
                                                        category: newCategory, from: account, to: account, date: transDate, inRealm: self.testRealm)

                                let prevfAccount = Account.with(key: account.id, inRealm: self.testRealm)
                                expect(prevfAccount?.currentAmount) == 10000
                                expect(prevfAccount?.totalIncome) == 10000
                                expect(prevfAccount?.totalExpenses) == 0
                                expect(prevfAccount?.transactionsToSelf.count) == 1
                                expect(prevfAccount?.transactionsFromSelf.count) == 1

                                let prevtAccount = Account.with(key: newAccount.id, inRealm: self.testRealm)
                                expect(prevtAccount?.currentAmount) == 0
                                expect(prevtAccount?.totalIncome) == 0
                                expect(prevtAccount?.totalExpenses) == 0
                                expect(prevtAccount?.transactionsToSelf.count) == 0
                                expect(prevtAccount?.transactionsFromSelf.count) == 0
                            })
                        })
                    })
                })
            })

            describe("all() of account", {
                it("returns all Transactions of given account sorted by transactionDate", closure: {
                    self.createTransactions(n: 3)
                    let transactions = Transaction.all(in: self.testRealm, fromAccount: account)
                    expect(transactions.count) == 3
                    expect(transactions[0].transactionDate) < transactions[1].transactionDate
                    expect(transactions[1].transactionDate) < transactions[2].transactionDate
                    expect(transactions[0].toAccount) == account
                    expect(transactions[1].toAccount) == account
                    expect(transactions[2].toAccount) == account
                })
            })

            describe("all() of category", {
                it("returns all Transactions of given category sorted by transactionDate", closure: {
                    self.createTransactions(n: 3)
                    let transactions = Transaction.all(in: self.testRealm, underCategory: category)
                    expect(transactions.count) == 3
                    expect(transactions[0].transactionDate) < transactions[1].transactionDate
                    expect(transactions[1].transactionDate) < transactions[2].transactionDate
                    expect(transactions[0].category) == category
                    expect(transactions[1].category) == category
                    expect(transactions[2].category) == category
                })
            })

            describe("delete()", {

                var expenseTransaction: Transaction!
                var incomeTransaction: Transaction!
                var transferTransaction: Transaction!
                var newAccount: Account!

                beforeEach {
                    newAccount = Account(value: ["id": "accnt2",
                                                 "name": "My Cash",
                                                 "type": cashAccountType,
                                                 "initialAmount": 0.0,
                                                 "currentAmount": 0.0,
                                                 "totalExpenses": 0.0,
                                                 "totalIncome": 0.0,
                                                 "color": "#AAAAAA",
                                                 "dateOpened": Date()])

                    let incomeCategory = Category(id: "cat1", type: .income, name: "Salary", icon: "salary.jpg")

                    expenseTransaction = Transaction(type: .expense, name: "Transaction", image: nil,
                                                     description: "Desc", amount: 100, category: category,
                                                     from: account, to: account, date: Date())
                    incomeTransaction = Transaction(type: .income, name: "Salary", image: nil,
                                                    description: "January Salary", amount: 10000,
                                                    category: incomeCategory, from: account, to: account, date: Date())
                    transferTransaction = Transaction(type: .transfer, name: "Allowance", image: nil,
                                                      description: "Cash allowance", amount: 500, category: nil,
                                                      from: account, to: newAccount, date: transDate)
                    expenseTransaction.save(toRealm: self.testRealm)
                    incomeTransaction.save(toRealm: self.testRealm)
                    transferTransaction.save(toRealm: self.testRealm)

                    expenseTransaction.delete(in: self.testRealm)
                    incomeTransaction.delete(in: self.testRealm)
                    transferTransaction.delete(in: self.testRealm)
                }

                it("deletes entry from database", closure: {
                    let transactions = self.testRealm.objects(Transaction.self)
                    expect(transactions.count) == 0
                })

                it("should be deleted from the account it belongs to", closure: {
                    let account1 = Account.with(key: "accnt1", inRealm: self.testRealm)
                    let account2 = Account.with(key: "accnt2", inRealm: self.testRealm)
                    expect(account1?.transactionsToSelf.count) == 0
                    expect(account1?.transactionsFromSelf.count) == 0
                    expect(account2?.transactionsToSelf.count) == 0
                    expect(account2?.transactionsFromSelf.count) == 0
                })

                context("deleted transaction is an expense", {
                    it("its amount should be re-added back to account's total amount and subtracted to account's total expenses", closure: {
                        let account1 = Account.with(key: "accnt1", inRealm: self.testRealm)
                        expect(account1?.currentAmount) == 0
                        expect(account1?.totalIncome) == 0
                        expect(account1?.totalExpenses) == 0
                    })

                    context("deleted transaction has associated bill", {
                        it("bill entry should be marked as unpaid") {
                            let bill = Bill(value: ["id": "bill0",
                                                "amount": 2500,
                                                "name": "Postpaid Bill",
                                                "postDueReminder": "never",
                                                "preDueReminder": "oneDay",
                                                "repeatSchedule": "monthly",
                                                "startDate": Date(),
                                                "category": category])

                            var entry = BillEntry(dueDate: Date(), for: bill)
                            bill.save(toRealm: self.testRealm)
                            entry.save(toRealm: self.testRealm)
                            entry.pay(amount: 3000, description: "", fromAccount: account,
                                      datePaid: Date(), inRealm: self.testRealm)

                            let transactionBill = Transaction.all(in: self.testRealm, underBill: bill).last!
                            transactionBill.delete(in: self.testRealm)

                            entry = BillEntry.all(in: self.testRealm, for: bill).last!
                            expect(entry.status) == BillEntryStatus.unpaid.rawValue
                            expect(entry.datePaid).to(beNil())
                        }
                    })
                })

                context("deleted transaction is an income", {
                    it("its amount should be subtracted from account's total amount and subtracted to account's total income", closure: {
                        let account1 = Account.with(key: "accnt1", inRealm: self.testRealm)
                        expect(account1?.currentAmount) == 0
                        expect(account1?.totalIncome) == 0
                        expect(account1?.totalExpenses) == 0
                    })
                })

                context("deleted transaction is a transfer", {
                    it("amount should be added to FROM ACCOUNT's total amount and subtracted to TO ACCOUNT's account's total amount", closure: {
                        let account1 = Account.with(key: "accnt1", inRealm: self.testRealm)
                        expect(account1?.currentAmount) == 0
                        expect(account1?.totalIncome) == 0
                        expect(account1?.totalExpenses) == 0

                        let account2 = Account.with(key: "accnt2", inRealm: self.testRealm)
                        expect(account2?.currentAmount) == 0
                        expect(account2?.totalIncome) == 0
                        expect(account2?.totalExpenses) == 0
                    })
                })
            })
        }
    }

    func createTransactions(n: Int) {
        let category = mtrckr.Category.with(key: "cat0", inRealm: self.testRealm)!
        let account = Account.with(key: "accnt1", inRealm: self.testRealm)!

        for i in 0..<n {
            let transaction = Transaction(type: .expense, name: "Transaction \(i)", image: nil,
                                          description: "Desc \(i)", amount: 100, category: category,
                                          from: account, to: account, date: Date())
            transaction.save(toRealm: self.testRealm)
        }
    }
}
