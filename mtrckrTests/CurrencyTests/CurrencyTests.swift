//
//  CurrencyTests.swift
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

class CurrencyTests: QuickSpec {

    var testRealm: Realm!

    override func spec() {

        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "CurrencyTests Database"
        }

        beforeEach {
            self.testRealm = try! Realm()
            try! self.testRealm.write {
                self.testRealm.deleteAll()
            }
        }

        describe("Model Currency") {
            describe("initializa with isoCode, symbol and state", {
                it("initializes and assign properties correctly ", closure: {
                    let currency = Currency(isoCode: "USD", symbol: "$", state: "USA")
                    expect(currency.isoCode) == "USD"
                    expect(currency.symbol) == "$"
                    expect(currency.state) == "USA"
                })
            })
        }

        describe("CRUD operations") {
            describe("save()", {
                it("saves object to database correctly", closure: {
                    let currency = Currency(isoCode: "USD", symbol: "$", state: "USA")
                    currency.save(toRealm: self.testRealm)

                    let currencyFromDatabase = self.testRealm.objects(Currency.self).last
                    expect(currencyFromDatabase?.isoCode) == "USD"
                    expect(currencyFromDatabase?.symbol) == "$"
                    expect(currencyFromDatabase?.state) == "USA"
                })
            })

            describe("update()", {
                it("updates values if object already exists", closure: {
                    let currency = Currency(isoCode: "USD", symbol: "$", state: "USA")
                    currency.save(toRealm: self.testRealm)

                    let currencyFromDatabase = self.testRealm.objects(Currency.self).last
                    let updatedCurrency = Currency(isoCode: "USD", symbol: "US $", state: "United States of America")
                    currencyFromDatabase?.update(to: updatedCurrency, in: self.testRealm)

                    let currencies = Currency.all(in: self.testRealm)
                    expect(currencies.count) == 1
                    expect(currencies[0].symbol) == "US $"
                    expect(currencies[0].state) == "United States of America"
                })
            })

            describe("all()", {
                it("returns all Currencies sorted by isoCode", closure: {
                    self.createCurrencies(n: 3)
                    let currencies = Currency.all(in: self.testRealm)
                    expect(currencies.count) == 3
                    expect(currencies[0].isoCode) == "code0"
                    expect(currencies[1].isoCode) == "code1"
                    expect(currencies[2].isoCode) == "code2"
                })
            })

            describe("delete()", {
                it("deletes object from database", closure: {
                    self.createCurrencies(n: 3)
                    let firstCurrency = Currency.with(key: "code0", inRealm: self.testRealm)
                    firstCurrency?.delete(in: self.testRealm)

                    let currencies = Currency.all(in: self.testRealm)
                    expect(currencies.count) == 2
                    expect(currencies[0].isoCode) == "code1"
                    expect(currencies[1].isoCode) == "code2"
                })
            })
        }
    }

    func createCurrencies(n: Int) {
        for i in 0..<n {
            Currency(isoCode: "code\(i)", symbol: "\(i)", state: "state \(i)").save(toRealm: testRealm)
        }
    }

}
