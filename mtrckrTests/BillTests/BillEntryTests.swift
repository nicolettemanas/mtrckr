//
//  BillEntryTests.swift
//  mtrckr
//
//  Created by User on 4/7/17.
//
//

import XCTest
import Quick
import Nimble
import RealmSwift
@testable import mtrckr

class BillEntryTests: QuickSpec {

    var testRealm: Realm!

    override func spec() {

        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "BillEntryTests Database"
        }

        beforeEach {
            self.testRealm = try! Realm()
            try! self.testRealm.write {
                self.testRealm.deleteAll()
            }
        }

        describe("Model BillEntry") {
            var bill: Bill!
            var dueDate: Date!
            var billEntry: BillEntry!

            beforeEach {
                let currency = Currency(isoCode: "USD", symbol: "`$", state: "USA")
                let user = User(id: "user1", name: "", email: "", image: "", currency: currency)
                let category = Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg")

                dueDate = Date()
                bill = Bill(value: ["id": "bill0",
                                    "amount": 2500,
                                    "name": "Postpaid Bill",
                                    "postDueReminder": "never",
                                    "preDueReminder": "oneDay",
                                    "repeatSchedule": "monthly",
                                    "startDate": Date(),
                                    "user": user,
                                    "category": category])
            }

            context("initialize with values dueDate and bill", {

                beforeEach {
                    let b = BillEntry(dueDate: dueDate, for: bill)
                    b.save(toRealm: self.testRealm)
                    billEntry = self.testRealm.objects(BillEntry.self).last!
                }

                it("initializes and assign properties correctly", closure: {
                    expect(billEntry.dueDate) == dueDate
                    expect(billEntry.bill) == bill
                })

                it("status must be unpaid and datePaid must be nil", closure: {
                    expect(billEntry.status) == BillEntryStatus.unpaid.rawValue
                    expect(billEntry.datePaid).to(beNil())
                })

                it("amount must be the same as the bill", closure: {
                    expect(billEntry.amount) == bill.amount
                })
            })

            context("initialize with json key-value", {

                var datePaid: Date!

                beforeEach {
                    datePaid = Date()
                    dueDate = Date()
                    billEntry = BillEntry(value: ["id": "billEntry0",
                                                      "amount": 2800,
                                                      "dueDate": dueDate,
                                                      "datePaid": datePaid,
                                                      "bill": bill,
                                                      "status": BillEntryStatus.paid.rawValue])

                    billEntry.save(toRealm: self.testRealm)
                }

                it("initializes and assign properties correctly", closure: {
                    let billEntryFromDb = self.testRealm.objects(BillEntry.self).last!
                    expect(billEntryFromDb.dueDate) == dueDate
                    expect(billEntryFromDb.bill) == bill
                    expect(billEntryFromDb.amount) == 2800
                    expect(billEntryFromDb.datePaid) == datePaid
                    expect(billEntryFromDb.status) == BillEntryStatus.paid.rawValue
                    expect(billEntryFromDb.id) == "billEntry0"
                })
            })
        }

        describe("CRUD operations") {

            var currency: Currency!
            var user: User!
            var category: mtrckr.Category!
            var dueDate: Date!
            var bill: Bill!
            var billEntry: BillEntry!

            beforeEach {
                currency = Currency(isoCode: "USD", symbol: "$", state: "USA")
                category = Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg")
                user = User(id: "user0", name: "", email: "", image: "", currency: currency)
                dueDate = Date()
                bill = Bill(value: ["id": "bill0",
                                    "amount": 2500,
                                    "name": "Postpaid Bill",
                                    "postDueReminder": "never",
                                    "preDueReminder": "oneDay",
                                    "repeatSchedule": "monthly",
                                    "startDate": Date(),
                                    "user": user,
                                    "category": category])

                currency.save(toRealm: self.testRealm)
                category.save(toRealm: self.testRealm)
                user.save(toRealm: self.testRealm)
                bill.save(toRealm: self.testRealm)
            }

            describe("save()", {

                beforeEach {
                    let b = BillEntry(dueDate: dueDate, for: bill)
                    b.save(toRealm: self.testRealm)
                    billEntry = self.testRealm.objects(BillEntry.self).last!
                }

                it("saves object to database correctly", closure: {
                    expect(billEntry.dueDate) == dueDate
                    expect(billEntry.bill) == bill
                    expect(billEntry.status) == BillEntryStatus.unpaid.rawValue
                    expect(billEntry.datePaid).to(beNil())
                    expect(billEntry.amount) == bill.amount

                })

                it("reflects as BillEntry under Bill", closure: {
                    let bill = Bill.with(key: bill.id, inRealm: self.testRealm)
                    expect(bill?.entries.count) == 1
                    expect(bill?.entries[0]) == billEntry
                })
            })

            describe("update()", {
                beforeEach {
                    let b = BillEntry(dueDate: dueDate, for: bill)
                    b.save(toRealm: self.testRealm)
                    billEntry = self.testRealm.objects(BillEntry.self).last!
                }

                describe("updating the amount", {
                    it("updates values if object already exists", closure: {
                        billEntry.update(amount: 3000, inRealm: self.testRealm)
                        let entries = self.testRealm.objects(BillEntry.self)
                        expect(entries.count) == 1
                        expect(entries[0].amount) == 3000
                    })
                })

                describe("paying a bill entry") {

                    let datePaid = Date()

                    beforeEach {

                        let cashAccountType = AccountType(typeId: 1, name: "My Cash", icon: "cash.jpg")
                        let account = Account(value: ["id": "accnt1",
                                                      "name": "My Cash",
                                                      "type": cashAccountType,
                                                      "initialAmount": 10.0,
                                                      "currentAmount": 20.0,
                                                      "totalExpenses": 100.0,
                                                      "totalIncome": 30.0,
                                                      "color": "#AAAAAA",
                                                      "dateOpened": Date(),
                                                      "user": user
                            ])

                        cashAccountType.save(toRealm: self.testRealm)
                        account.save(toRealm: self.testRealm)

                        billEntry.pay(amount: 3000, description: "First bill",
                                      fromAccount: account, datePaid: datePaid, inRealm: self.testRealm)
                    }

                    it("marks entry as paid", closure: {
                        let entries = self.testRealm.objects(BillEntry.self)
                        expect(entries.count) == 1
                        expect(entries[0].status) == BillEntryStatus.paid.rawValue
                        expect(entries[0].datePaid) == datePaid
                    })

                    it("generates corresponding transaction", closure: {
                        let transactionForBill = Transaction.all(in: self.testRealm, underBill: bill)
                        expect(transactionForBill.count) == 1
                    })
                }

                describe("skipping a bill entry", {
                    beforeEach {
                        billEntry.skip(inRealm: self.testRealm)
                    }

                    it("marks entry as skipped", closure: {
                        let entries = self.testRealm.objects(BillEntry.self)
                        expect(entries.count) == 1
                        expect(entries[0].status) == BillEntryStatus.skipped.rawValue
                    })
                })

                //TODO: update from skipped to unpaid
                //TODO: update from paid to unpaid
            })

            describe("all() of bill", {

                it("returns all BillEntries of given bill sorted by dueDate", closure: {
                    self.createBillEntries(n: 3, for: bill)

                    let entries = BillEntry.all(in: self.testRealm, for: bill)
                    expect(entries.count) == 3
                    expect(entries[0].dueDate) < entries[1].dueDate
                    expect(entries[1].dueDate) < entries[2].dueDate
                })
            })

            describe("delete()", {

                var firstBillEntry: BillEntry!
                var entryId: String!

                beforeEach {
                    self.createBillEntries(n: 3, for: bill)
                    firstBillEntry = BillEntry.all(in: self.testRealm, for: bill)[0]
                    entryId = firstBillEntry.id
                    firstBillEntry?.delete(in: self.testRealm)
                }

                it("deletes entry from database", closure: {
                    let deletedEntry = BillEntry.with(key: entryId, inRealm: self.testRealm)
                    let allBillEntries = BillEntry.all(in: self.testRealm, for: bill)
                    expect(deletedEntry).to(beNil())
                    expect(allBillEntries.count) == 2
                })

                it("deletes entry under Bill", closure: {
                    let billFromDb = Bill.with(key: bill.id, inRealm: self.testRealm)
                    expect(billFromDb?.entries.count) == 2
                })

                context("bill is paid", closure: {
                    it("deletes transaction generated", closure: {
                        let transactionFromBill = Transaction.all(in: self.testRealm, underBill: bill)
                        expect(transactionFromBill.count) == 0
                    })
                })
            })
        }
    }

    func createBillEntries(n: Int, for bill: Bill) {
        for _ in 0..<n {
            BillEntry(dueDate: Date(), for: bill).save(toRealm: self.testRealm)
        }
    }
}
