//
//  TransactionsInteractorTests.swift
//  mtrckrTests
//
//  Created by User on 8/1/17.
//

import UIKit
import Quick
import Nimble
import Realm
import RealmSwift
@testable import mtrckr

class TransactionsInteractorTests: QuickSpec {
    
    var identifier = "TransactionsInteractorTests Database"
    
    override func spec() {
        describe("TransactionsInteractor") {
            
            var realm: Realm?
            var category: mtrckr.Category!
            var cashAccountType: AccountType!
            var account: Account!
            var interactor: TransactionsInteractor!
            
            beforeEach {
                var config = Realm.Configuration()
                config.inMemoryIdentifier = self.identifier
                realm = try? Realm(configuration: config)
                try! realm?.write {
                    realm!.deleteAll()
                }
                
                interactor = TransactionsInteractor(with: RealmAuthConfig())
                interactor.realmContainer = MockRealmContainer(memoryIdentifier: self.identifier)
                interactor.realmContainer?.setDefaultRealm(to: .offline)
                
                category = Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg", color: "")
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
            }
            
            context("when asked to retrieve Transactions recorded in a given date", {
                it("calls Transaction.all(inRealm, date)", closure: {
                    // TODO: Cannot test calling of static methods of subclass of Realm Object
                })
            })
            
            context("when asked to edit a transaction", {
                var transaction: Transaction!
                beforeEach {
                    transaction = Transaction(type: .expense, name: "Breakfast", image: nil,
                                              description: "Subway: Spicy Italian",
                                              amount: 99.0, category: category, from: account,
                                              to: account, date: Date())
                }
                
                context("Transaction exsists in realm", {
                    var updated: Transaction!
                    beforeEach {
                        transaction.save(toRealm: realm!)
                        updated = Transaction(type: .expense, name: "Breakfast", image: nil,
                                              description: "Subway: Spicy Italian",
                                              amount: 99.0, category: category, from: account,
                                              to: account, date: Date())
                        updated.id = transaction.id
                        updated.name = ""
                        updated.amount = 100
                    }
                    
                    it("doesn't throw an exception", closure: {
                        expect(expression: { try interactor.editTransaction(transaction: updated) }).toNot(throwError())
                    })
                    
                    describe("udpates in database", {
                        beforeEach {
                            try? interactor.editTransaction(transaction: updated)
                        }
                        itBehavesLike("transaction can be found in database") { ["transaction": updated, "realm": realm!] }
                    })
                })
                
                context("Transaction does not exist in realm", {
                    it("throws an exception", closure: {
                        expect(expression: { try interactor.editTransaction(transaction: transaction) }).to(throwError())
                    })
                })
            })
        }
    }
}
