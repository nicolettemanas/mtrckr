//
//  UserTests.swift
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

class UserTests: QuickSpec {
    
    var testRealm: Realm!
    
    override func spec() {
        
        var user: User!
        var currency: Currency!
        
        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "UserTests Database"
        }
        
        beforeEach {
            self.testRealm = try! Realm()
            try! self.testRealm.write {
                self.testRealm.deleteAll()
            }
            
            currency = Currency(isoCode: "PHP", symbol: "P", state: "Philippines")
            user = User(id: "user0", name: "Jean", email: "email@sample.com", image: "img.jpg", currency: currency)
        }
        
        describe("Model User") {
            describe("initializa with id, name, email, image, currency", {
                it("initializes and assign properties correctly ", closure: {
                    expect(user.id) == "user0"
                    expect(user.name) == "Jean"
                    expect(user.email) == "email@sample.com"
                    expect(user.image) == "img.jpg"
                    expect(user.currency) == currency
                })
            })
        }
        
        describe("CRUD operations") {
            describe("save()", {
                it("saves object to database correctly", closure: {
                    user.save(toRealm: self.testRealm)
                    
                    let userFromDatabase = self.testRealm.objects(User.self).last!
                    expect(userFromDatabase.id) == "user0"
                    expect(userFromDatabase.name) == "Jean"
                    expect(userFromDatabase.email) == "email@sample.com"
                    expect(userFromDatabase.image) == "img.jpg"
                    expect(userFromDatabase.currency) == currency
                })
            })
            
            describe("update()", {
                it("updates values if object already exists", closure: {
                    user.save(toRealm: self.testRealm)
                    let newCurrency = Currency(isoCode: "USD", symbol: "$", state: "USA")
                    let userFromDatabase = self.testRealm.objects(User.self).last
                    let updatedUser = User(id: "user0", name: "Jean Manas", email: "email1@sample.com", image: "/img.jpg", currency: newCurrency)
                    
                    userFromDatabase?.update(to: updatedUser, in: self.testRealm)
                    
                    let usrs = User.all(in: self.testRealm)
                    expect(usrs.count) == 1
                    expect(usrs[0].name) == "Jean Manas"
                    expect(usrs[0].email) == "email1@sample.com"
                    expect(usrs[0].image) == "/img.jpg"
                    expect(usrs[0].currency) == newCurrency
                })
            })
            
            describe("all()", {
                it("returns all Users sorted by name", closure: {
                    self.createUsers(n: 3)
                    let users = User.all(in: self.testRealm)
                    expect(users.count) == 3
                    expect(users[0].id) == "user0"
                    expect(users[1].id) == "user1"
                    expect(users[2].id) == "user2"
                })
            })
            
            describe("delete()", {
                
                beforeEach {
                    self.createUsers(n: 3)
                    let firstUser = User.with(key: "user0", inRealm: self.testRealm)
                    firstUser?.delete(in: self.testRealm)
                }
                
                it("deletes object from database", closure: {
                    let users = User.all(in: self.testRealm)
                    expect(users.count) == 2
                    expect(users[0].id) == "user1"
                    expect(users[1].id) == "user2"
                })
                
                it("deletes accounts under user") {
                    let accnt0 = Account.with(key: "accnt0", inRealm: self.testRealm)
                    let accnt1 = Account.with(key: "accnt1", inRealm: self.testRealm)
                    let accnt2 = Account.with(key: "accnt2", inRealm: self.testRealm)
                    
                    expect(accnt0).to(beNil())
                    expect(accnt1).toNot(beNil())
                    expect(accnt2).toNot(beNil())
                }
                
                it("deletes the deleted user's custom categories") {
                    let categories = mtrckr.Category.all(in: self.testRealm)
                    expect(categories.count) == 2
                    expect(categories[0].name) == "Category 1"
                    expect(categories[1].name) == "Category 2"
                }
                
//                it("deletes budgets under user") {
//                    
//                }
                
                it("deletes bills under user") {
                    let bill0 = Bill.with(key: "bill0", inRealm: self.testRealm)
                    let bill1 = Bill.with(key: "bill1", inRealm: self.testRealm)
                    let bill2 = Bill.with(key: "bill2", inRealm: self.testRealm)
                    
                    expect(bill0).to(beNil())
                    expect(bill1).toNot(beNil())
                    expect(bill2).toNot(beNil())
                }
            })
        }
    }
    
    func createUsers(n: Int) {
        let cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
        let newCurrency = Currency(isoCode: "USD", symbol: "$", state: "USA")
        
        for i in 0..<n {
            let user = User(id: "user\(i)", name: "User \(i)", email: "email\(i)1@sample.com",
                image: "/img\(i).jpg", currency: newCurrency)
            let category = mtrckr.Category(type: .expense, name: "Category \(i)", icon: "", user: user)
            let account = Account(value: ["id": "accnt\(i)",
                "name": "Account \(i)",
                "type": cashAccountType,
                "initialAmount": 0.0,
                "currentAmount": 0.0,
                "totalExpenses": 0.0,
                "totalIncome": 0.0,
                "color": "",
                "dateOpened": Date(),
                "user": user])
            
            let bill = Bill(value: ["id": "bill\(i)",
                         "amount": 2500,
                         "name": "Bill \(i)",
                         "postDueReminder": "never",
                         "preDueReminder": "oneDay",
                         "repeatSchedule": "monthly",
                         "startDate": Date(),
                         "user": user,
                         "category": category])
            user.save(toRealm: self.testRealm)
            account.save(toRealm: self.testRealm)
            category.save(toRealm: self.testRealm)
            bill.save(toRealm: self.testRealm)
        }
    }
}
