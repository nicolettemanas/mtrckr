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
        
        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "CategoryTests Database"
        }
        
        beforeEach {
            self.testRealm = try! Realm()
            try! self.testRealm.write {
                self.testRealm.deleteAll()
            }
        }
        
        describe("Model Category") {
            describe("initializa with id, type, name, icon", {
                it("initializes and assign properties correctly ", closure: {
                    let cat = Category(id: 1, type: .expense, name: "Food", icon: "food.jpg")
                    expect(cat.id) == 1
                    expect(cat.type) == CategoryType.expense.rawValue
                    expect(cat.name) == "Food"
                    expect(cat.icon) == "food.jpg"
                })
            })
        }
        
        describe("CRUD operations") {
            describe("save()", {
                it("saves object to database correctly", closure: {
                    let cat = Category(id: 1, type: .expense, name: "Food", icon: "food.jpg")
                    cat.save(toRealm: self.testRealm)
                    
                    let catFromDatabase = self.testRealm.objects(Category.self).last
                    expect(catFromDatabase?.id) == 1
                    expect(catFromDatabase?.type) == CategoryType.expense.rawValue
                    expect(catFromDatabase?.name) == "Food"
                    expect(catFromDatabase?.icon) == "food.jpg"
                })
            })
            
            describe("update()", {
                it("updates values if object already exists", closure: {
                    let cat = Category(id: 1, type: .expense, name: "Food", icon: "food.jpg")
                    cat.save(toRealm: self.testRealm)
                    
                    let catFromDatabase = self.testRealm.objects(Category.self).last
                    let updatedCategory = Category(id: 1, type: .income, name: "Salary", icon: "salary.jpg")
                    catFromDatabase?.update(to: updatedCategory, in: self.testRealm)
                    
                    let categories = Category.all(in: self.testRealm)
                    expect(categories.count) == 1
                    expect(categories[0].type) == CategoryType.income.rawValue
                    expect(categories[0].name) == "Salary"
                    expect(categories[0].icon) == "salary.jpg"
                })
            })
            
            describe("all()", {
                context("of type income", { 
                    it("returns all income categories sorted by name", closure: {
                        self.createIncomes(n: 3)
                        self.createExpenses(n: 3)
                        let incomeCategories = Category.all(in: self.testRealm, ofType: .income)
                        expect(incomeCategories.count) == 3
                        expect(incomeCategories[0].id) == 10
                        expect(incomeCategories[1].id) == 11
                        expect(incomeCategories[2].id) == 12
                    })
                })
                
                context("of type expense", {
                    it("returns all expense categories sorted by name", closure: {
                        self.createIncomes(n: 3)
                        self.createExpenses(n: 3)
                        let expenseCategories = Category.all(in: self.testRealm, ofType: .expense)
                        expect(expenseCategories.count) == 3
                        expect(expenseCategories[0].id) == 20
                        expect(expenseCategories[1].id) == 21
                        expect(expenseCategories[2].id) == 22
                    })
                })
                
                context("all", { 
                    it("returns all categories sorted by name", closure: {
                        self.createIncomes(n: 3)
                        self.createExpenses(n: 3)
                        let expenseCategories = Category.all(in: self.testRealm)
                        expect(expenseCategories.count) == 6
                        expect(expenseCategories[0].id) == 10
                        expect(expenseCategories[1].id) == 11
                        expect(expenseCategories[2].id) == 12
                        expect(expenseCategories[3].id) == 20
                        expect(expenseCategories[4].id) == 21
                        expect(expenseCategories[5].id) == 22
                    })
                })
            })
            
            describe("delete()", {
                it("deletes object from database", closure: {
                    self.createExpenses(n: 3)
                    let firstCategory = Category.with(key: 20, inRealm: self.testRealm)
                    firstCategory?.delete(in: self.testRealm)
                    
                    let categories = Category.all(in: self.testRealm)
                    expect(categories.count) == 2
                    expect(categories[0].id) == 21
                    expect(categories[1].id) == 22
                })
            })
        }
    }
    
    func createIncomes(n: Int) {
        for i in 10..<n+10 {
            Category(id: i, type: .income, name: "cat \(i)", icon: "icon \(i)").save(toRealm: self.testRealm)
        }
    }
    
    func createExpenses(n: Int) {
        for i in 20..<n+20 {
            Category(id: i, type: .expense, name: "cat \(i)", icon: "icon \(i)").save(toRealm: self.testRealm)
        }
    }
}
