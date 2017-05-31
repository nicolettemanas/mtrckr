//
//  CategoryTests.swift
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

class CategoryTests: QuickSpec {

    var testRealm: Realm!

    override func spec() {

        var user: User!
        var currency: Currency!

        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "CategoryTests Database"
        }

        beforeEach {
            self.testRealm = try! Realm()
            try! self.testRealm.write {
                self.testRealm.deleteAll()
            }

            currency = Currency(id: "Curr1", isoCode: "PHP", symbol: "P", state: "Philippines")
            user = User(id: "user0", name: "Jean", email: "email@sample.com", image: "img.jpg", currency: currency)
            user.save(toRealm: self.testRealm)
        }

        describe("Model Category") {
            describe("initializa with id, type, name, icon", {
                it("initializes and assign properties correctly ", closure: {
                    let cat = Category(id: "cat1", type: .expense, name: "Food", icon: "food.jpg")
                    expect(cat.id) == "cat1"
                    expect(cat.type) == CategoryType.expense.rawValue
                    expect(cat.name) == "Food"
                    expect(cat.icon) == "food.jpg"
                })
            })
        }

        describe("CRUD operations") {
            describe("save()", {

                context("normal category", {
                    it("saves object to database correctly", closure: {
                        let cat = Category(id: "cat1", type: .expense, name: "Food", icon: "food.jpg")
                        cat.save(toRealm: self.testRealm)

                        let catFromDatabase = self.testRealm.objects(Category.self).last
                        expect(catFromDatabase?.id) == "cat1"
                        expect(catFromDatabase?.type) == CategoryType.expense.rawValue
                        expect(catFromDatabase?.name) == "Food"
                        expect(catFromDatabase?.icon) == "food.jpg"
                    })
                })

                context("custom category", {

                    beforeEach {
                        let cat = Category(type: .expense, name: "Personal", icon: "person.jpg")
                        cat.save(toRealm: self.testRealm)
                    }

                    it("saves object to database correctly", closure: {
                        let catFromDatabase = self.testRealm.objects(Category.self).last
                        expect(catFromDatabase?.type) == CategoryType.expense.rawValue
                        expect(catFromDatabase?.name) == "Personal"
                        expect(catFromDatabase?.icon) == "person.jpg"
                        expect(catFromDatabase?.isCustomized) == true
                    })

//                    it("reflects under user's category", closure: {
//                        let catsOfUser = User.with(key: user.id, inRealm: self.testRealm)?.customCategories
//                        expect(catsOfUser?.count) == 1
//                        expect(catsOfUser?[0].name) == "Personal"
//                    })
                })
            })

            describe("update()", {
                it("updates values if object already exists", closure: {
                    let cat = Category(id: "cat1", type: .expense, name: "Food", icon: "food.jpg")
                    cat.save(toRealm: self.testRealm)

                    let catFromDatabase = self.testRealm.objects(Category.self).last
                    let updatedCategory = Category(id: "cat1", type: .income, name: "Salary", icon: "salary.jpg")
                    catFromDatabase?.update(to: updatedCategory, in: self.testRealm)

                    let categories = Category.all(in: self.testRealm)
                    expect(categories.count) == 1
                    expect(categories[0].type) == CategoryType.income.rawValue
                    expect(categories[0].name) == "Salary"
                    expect(categories[0].icon) == "salary.jpg"

                    // TODO: update accounts and transactions affected
                })
            })

            describe("all()", {
                context("of type income", {
                    it("returns all income categories sorted by name", closure: {
                        self.createIncomes(n: 3)
                        self.createExpenses(n: 3)
                        let incomeCategories = Category.all(in: self.testRealm, ofType: .income)
                        expect(incomeCategories.count) == 3
                        expect(incomeCategories[0].id) == "cat10"
                        expect(incomeCategories[1].id) == "cat11"
                        expect(incomeCategories[2].id) == "cat12"
                    })
                })

                context("of type expense", {
                    it("returns all expense categories sorted by name", closure: {
                        self.createIncomes(n: 3)
                        self.createExpenses(n: 3)
                        let expenseCategories = Category.all(in: self.testRealm, ofType: .expense)
                        expect(expenseCategories.count) == 3
                        expect(expenseCategories[0].id) == "cat20"
                        expect(expenseCategories[1].id) == "cat21"
                        expect(expenseCategories[2].id) == "cat22"
                    })
                })

                context("of user", {
                    it("returns all custom categories of given user", closure: {
                        let categories = self.createCustomCategories(n: 3, for: user)
                        let customCategories = Category.all(in: self.testRealm, customized: true)
                        expect(customCategories[0]) == categories[0]
                        expect(customCategories[1]) == categories[1]
                        expect(customCategories[2]) == categories[2]
                    })
                })

                context("all", {
                    it("returns all categories sorted by name", closure: {
                        self.createIncomes(n: 3)
                        self.createExpenses(n: 3)
                        let expenseCategories = Category.all(in: self.testRealm)
                        expect(expenseCategories.count) == 6
                        expect(expenseCategories[0].id) == "cat10"
                        expect(expenseCategories[1].id) == "cat11"
                        expect(expenseCategories[2].id) == "cat12"
                        expect(expenseCategories[3].id) == "cat20"
                        expect(expenseCategories[4].id) == "cat21"
                        expect(expenseCategories[5].id) == "cat22"
                    })
                })
            })

            describe("delete()", {
                context("normal category", {

                    var categoryToDelete: mtrckr.Category!
                    var account: Account!

                    beforeEach {
                        self.createExpenses(n: 3)
                        categoryToDelete = Category.with(key: "cat20", inRealm: self.testRealm)
                        let bill = Bill(value: ["id": "bill0",
                                                "amount": 500,
                                                "name": "Prepaid Bill",
                                                "postDueReminder": "oneDay",
                                                "preDueReminder": "never",
                                                "repeatSchedule": "weekly",
                                                "startDate": Date(),
                                                "category": categoryToDelete])
                        let cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
                        account = Account(value: ["id": "accnt1",
                                                  "name": "My Cash",
                                                  "type": cashAccountType,
                                                  "initialAmount": 10.0,
                                                  "currentAmount": 20.0,
                                                  "totalExpenses": 100.0,
                                                  "totalIncome": 30.0,
                                                  "color": "#AAAAAA",
                                                  "dateOpened": Date()])

                        bill.save(toRealm: self.testRealm)
                        cashAccountType.save(toRealm: self.testRealm)
                        account.save(toRealm: self.testRealm)
                        let transaction = Transaction(type: .expense, name: "Breakfast", image: nil,
                                                      description: "Subway: Spicy Italian", amount: 99.0, category: categoryToDelete,
                                                      from: account, to: account, date: Date())
                        transaction.save(toRealm: self.testRealm)
                        categoryToDelete?.delete(in: self.testRealm)
                    }

                    it("deletes object from database", closure: {
                        let categories = Category.all(in: self.testRealm)
                        expect(categories.count) == 2
                        expect(categories[0].id) == "cat21"
                        expect(categories[1].id) == "cat22"
                    })

                    it("deletes associated bills", closure: {
                        let bill = Bill.with(key: "bill0", inRealm: self.testRealm)
                        expect(bill).to(beNil())
                    })

                    it("deletes associated transactions", closure: {
                        let transactions = Transaction.all(in: self.testRealm, fromAccount: account)
                        expect(transactions.count) == 0
                    })
                })

                context("custom category", {
                    beforeEach {
                        let c = self.createCustomCategories(n: 3, for: user)
                        c[0].delete(in: self.testRealm)
                    }

                    it("deletes category from user", closure: {
                        let categories = Category.all(in: self.testRealm, customized: true)
                        expect(categories.count) == 2
                        expect(categories[0].name) == "Custom category 31"
                        expect(categories[1].name) == "Custom category 32"
                    })
                })
            })
        }
    }

    func createIncomes(n: Int) {
        for i in 10..<n+10 {
            Category(id: "cat\(i)", type: .income, name: "cat \(i)", icon: "icon \(i)").save(toRealm: self.testRealm)
        }
    }

    func createExpenses(n: Int) {
        for i in 20..<n+20 {
            Category(id: "cat\(i)", type: .expense, name: "cat \(i)", icon: "icon \(i)").save(toRealm: self.testRealm)
        }
    }

    func createCustomCategories(n: Int, for user: User) -> [mtrckr.Category] {
        var cat: [mtrckr.Category] = []
        for i in 30..<n+30 {
            let c = mtrckr.Category(type: .expense, name: "Custom category \(i)", icon: "custom\(i).jpg")
            c.save(toRealm: self.testRealm)
            cat.append(c)
        }
        return cat
    }
}
