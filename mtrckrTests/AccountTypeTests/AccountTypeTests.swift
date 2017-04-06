//
//  AccountTypeTests.swift
//  mtrckr
//
//  Created by User on 4/5/17.
//
//

import XCTest
import Quick
import Nimble
import RealmSwift
@testable import mtrckr

class AccountTypeTests: QuickSpec {
    
    var testRealm: Realm!
    
    override func spec() {
        
        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "AccountTypeTests Database"
        }
        
        beforeEach {
            self.testRealm = try! Realm()
            try! self.testRealm.write {
                self.testRealm.deleteAll()
            }
        }
        
        describe("Model AccountType") { 
            describe("initialize with typeId, name and icon", {
                it("initializes and assign properties correctly", closure: {
                    let accountType = AccountType(typeId: 1, name: "Cash", icon: "")
                    expect(accountType.typeId) == 1
                    expect(accountType.name) == "Cash"
                    expect(accountType.icon) == ""
                })
            })
        }
        
        describe("CRUD operations") { 
            describe("save()", {
                it("saves object to database correctly", closure: { 
                    let accountType = AccountType(typeId: 1, name: "Cash", icon: "")
                    accountType.save(toRealm: self.testRealm)
                    
                    let accountTypeFromDatabase = self.testRealm.objects(AccountType.self).last
                    expect(accountTypeFromDatabase?.typeId) == 1
                    expect(accountTypeFromDatabase?.name) == "Cash"
                    expect(accountTypeFromDatabase?.icon) == ""
                })
            })
            
            describe("update()", { 
                it("updates values if object already exists", closure: {
                    let accountType = AccountType(typeId: 1, name: "Cash", icon: "")
                    accountType.save(toRealm: self.testRealm)
                    
                    let accountTypeFromDatabase = self.testRealm.objects(AccountType.self).last
                    let updatedAccountType = AccountType(typeId: 1, name: "Bank", icon: "default.png")
                    accountTypeFromDatabase?.update(to: updatedAccountType, in: self.testRealm)
                    
                    let accountTypes = AccountType.all(in: self.testRealm)
                    expect(accountTypes.count) == 1
                    expect(accountTypes[0].name) == "Bank"
                    expect(accountTypes[0].icon) == "default.png"
                    
                })
            })
            
            describe("all()", {
                it("returns all AccountTypes sorted by name", closure: {
                    self.createAccountTypes(n: 3)
                    let accountTypes = AccountType.all(in: self.testRealm)
                    expect(accountTypes.count) == 3
                    expect(accountTypes[0].name) == "AccountType 0"
                    expect(accountTypes[1].name) == "AccountType 1"
                    expect(accountTypes[2].name) == "AccountType 2"
                })
            })
            
            describe("delete()", { 
                it("deletes object from database", closure: { 
                    self.createAccountTypes(n: 3)
                    let firstAccountType = AccountType.with(key: 0, inRealm: self.testRealm)
                    firstAccountType?.delete(in: self.testRealm)
                    
                    let accountTypes = AccountType.all(in: self.testRealm)
                    expect(accountTypes.count) == 2
                    expect(accountTypes[0].name) == "AccountType 1"
                    expect(accountTypes[1].name) == "AccountType 2"
                })
            })
        }
    }
    
    func createAccountTypes(n: Int) {
        for i in 0..<n {
            AccountType(typeId: i, name: "AccountType \(i)", icon: "").save(toRealm: testRealm)
        }
    }
    
}
