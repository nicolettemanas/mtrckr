//
//  BillTests.swift
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

class BillTests: QuickSpec {

    var testRealm: Realm!

    override func spec() {

        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "BillTests Database"
        }

        beforeEach {
            self.testRealm = try! Realm()
            try! self.testRealm.write {
                self.testRealm.deleteAll()
            }
        }

        describe("Model Bill") {
            describe("initialize with values", {
                it("initializes and assign properties correctly", closure: {
                    let category = Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg", color: "")
                    let startDate = Date()

                    let bill = Bill(value: ["id": "bill0",
                                            "amount": 2500,
                                            "name": "Postpaid Bill",
                                            "postDueReminder": "never",
                                            "preDueReminder": "oneDay",
                                            "repeatSchedule": "monthly",
                                            "startDate": startDate,
                                            "category": category
                                            ])

                    expect(bill.id) == "bill0"
                    expect(bill.amount) == 2500
                    expect(bill.name) == "Postpaid Bill"
                    expect(bill.postDueReminder) == "never"
                    expect(bill.preDueReminder) == "oneDay"
                    expect(bill.repeatSchedule) == "monthly"
                    expect(bill.startDate) == startDate
//                    expect(bill.user) == user
                    expect(bill.category) == category
                })
            })

        }

        describe("CRUD operations") {

            var currency: Currency!
            var user: User!
            var category: mtrckr.Category!
            var startDate: Date!

            var bill: Bill!

            beforeEach {
                currency = Currency(id: "Curr1", isoCode: "USD", symbol: "$", state: "USA")
                category = Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg", color: "")
                user = User(id: "user0", name: "", email: "", image: "", currency: currency)
                startDate = Date()

                bill = Bill(value: ["id": "bill0",
                                    "amount": 2500,
                                    "name": "Postpaid Bill",
                                    "postDueReminder": "never",
                                    "preDueReminder": "oneDay",
                                    "repeatSchedule": "monthly",
                                    "startDate": startDate,
                                    "category": category
                    ])
            }

            describe("save()", {
                beforeEach {
                    bill.save(toRealm: self.testRealm)
                }

                it("saves object to database correctly", closure: {
                    let billFromDatabase = self.testRealm.objects(Bill.self).last!

                    expect(billFromDatabase.id) == "bill0"
                    expect(billFromDatabase.amount) == 2500
                    expect(billFromDatabase.name) == "Postpaid Bill"
                    expect(billFromDatabase.postDueReminder) == "never"
                    expect(billFromDatabase.preDueReminder) == "oneDay"
                    expect(billFromDatabase.repeatSchedule) == "monthly"
                    expect(billFromDatabase.startDate) == startDate
//                    expect(billFromDatabase.user) == user
                    expect(billFromDatabase.category) == category
                })

//                it("reflects as Bill under user", closure: {
//                    let user = User.with(key: user.id, inRealm: self.testRealm)
//                    expect(user?.bills.count) == 1
//                    expect(user?.bills[0].id) == "bill0"
//                })

                it("reflects in bills under category", closure: {
                    let category = mtrckr.Category.with(key: category.id, inRealm: self.testRealm)
                    expect(category?.bills.count) == 1
                    expect(category?.bills[0].id) == "bill0"
                })

//                it("creates billEntries from startDate to currentDate") {
//                    
//                }
            })

            describe("update()", {
                context("update all values from json/key-value", {
                    it("updates values if object already exists", closure: {
                        bill.save(toRealm: self.testRealm)

                        let billFromDatabase = self.testRealm.objects(Bill.self).last
                        let updatedBill = Bill(value: ["id": "bill0",
                                                       "amount": 500,
                                                       "name": "Prepaid Bill",
                                                       "postDueReminder": "oneDay",
                                                       "preDueReminder": "never",
                                                       "repeatSchedule": "weekly",
                                                       "startDate": startDate,
                                                       "category": category
                            ])

                        billFromDatabase!.update(to: updatedBill, in: self.testRealm)

                        let updatedBills = self.testRealm.objects(Bill.self)

                        expect(updatedBills.count) == 1
                        expect(updatedBills[0].id) == "bill0"
                        expect(updatedBills[0].amount) == 500
                        expect(updatedBills[0].name) == "Prepaid Bill"
                        expect(updatedBills[0].postDueReminder) == "oneDay"
                        expect(updatedBills[0].preDueReminder) == "never"
                        expect(updatedBills[0].repeatSchedule) == "weekly"
                        expect(updatedBills[0].startDate) == startDate
//                        expect(updatedBills[0].user) == user
                        expect(updatedBills[0].category) == category
                    })
                })

                context("user can only update amount, name, postDueReminder, preDueReminder and category", {

                    var billFromDatabase: Bill!
                    var anotherCategory: mtrckr.Category!

                    beforeEach {
                        bill.save(toRealm: self.testRealm)

                        anotherCategory = Category(id: "cat1", type: .expense, name: "Utilities2", icon: "util2.jpg", color: "")
                        billFromDatabase = self.testRealm.objects(Bill.self).last
                        billFromDatabase!.update(amount: 2000, name: "Postpaid bill2", postDueReminder: .threeDays,
                                                 preDueReminder: .never, category: anotherCategory, in: self.testRealm)
                    }

                    it("updates values if object already exists", closure: {
                        let updatedBills = Bill.all(in: self.testRealm)

                        expect(updatedBills.count) == 1
                        expect(updatedBills[0].id) == "bill0"
                        expect(updatedBills[0].amount) == 2000
                        expect(updatedBills[0].name) == "Postpaid bill2"
                        expect(updatedBills[0].postDueReminder) == "threeDays"
                        expect(updatedBills[0].preDueReminder) == "never"
//                        expect(updatedBills[0].user) == user
                        expect(updatedBills[0].category) == anotherCategory
                    })
                })

                context("Bill to update does not exist in realm") {
                    it("doesn't have any effect", closure: {
                        bill.save(toRealm: self.testRealm)

                        let anotherBill = Bill(value: ["id": "bill2",
                                                       "amount": 500,
                                                       "name": "Prepaid Bill",
                                                       "postDueReminder": "oneDay",
                                                       "preDueReminder": "never",
                                                       "repeatSchedule": "weekly",
                                                       "startDate": startDate,
                                                       "category": category ])

                        anotherBill.update(amount: 2000, name: "Postpaid bill2", postDueReminder: .threeDays,
                                           preDueReminder: .never, category: category, in: self.testRealm)

                        let bills = Bill.all(in: self.testRealm)
                        expect(bills.count) == 1

                        let bill = bills[0]
                        expect(bill.id) == "bill0"
                        expect(bill.amount) == 2500
                        expect(bill.name) == "Postpaid Bill"
                        expect(bill.postDueReminder) == "never"
                        expect(bill.preDueReminder) == "oneDay"
                        expect(bill.repeatSchedule) == "monthly"
                        expect(bill.startDate) == startDate
//                        expect(bill.user) == user
                        expect(bill.category) == category
                    })
                }
            })

            describe("all() of user", {
                it("returns all Bills of given user sorted by name", closure: {
                    self.createBills(n: 3, for: user)

                    let bills = Bill.all(in: self.testRealm)
                    expect(bills.count) == 3
                    expect(bills[0].id) == "bill0"
                    expect(bills[1].id) == "bill1"
                    expect(bills[2].id) == "bill2"
                })
            })

            describe("delete()", {
                beforeEach {
                    self.createBills(n: 3, for: user)
                    let firstBill = Bill.with(key: "bill0", inRealm: self.testRealm)
                    self.createBillEntries(n: 3, for: firstBill!)
                    firstBill?.delete(in: self.testRealm)
                }

                it("deletes Bill from database", closure: {
                    let bills = Bill.all(in: self.testRealm)
                    expect(bills.count) == 2
                    expect(bills[0].id) == "bill1"
                    expect(bills[1].id) == "bill2"
                })

                it("deletes bill entries under deleted Bill", closure: {
                    let entries = self.testRealm.objects(BillEntry.self)
                    expect(entries.count) == 0

                })

//                it("should be deleted from the user it belongs to", closure: {
//                    let user = User.with(key: user.id, inRealm: self.testRealm)
//                    expect(user?.bills.count) == 2
//                    expect(user?.bills[0].id) == "bill1"
//                    expect(user?.bills[1].id) == "bill2"
//                })
            })
        }
    }

    func createBills(n: Int, for user: User) {
        let category = Category(id: "cat0", type: .expense, name: "Utilities", icon: "util.jpg", color: "")

        for i in 0..<n {
            Bill(value: [
                "id": "bill\(i)",
                "amount": 500,
                "name": "Bill \(i)",
                "postDueReminder": "oneDay",
                "preDueReminder": "never",
                "repeatSchedule": "weekly",
                "startDate": Date(),
                "category": category
                ]).save(toRealm: self.testRealm)
        }
    }

    func createBillEntries(n: Int, for bill: Bill) {
        for _ in 0..<n {
            BillEntry(dueDate: Date(), for: bill).save(toRealm: self.testRealm)
        }
    }

}
