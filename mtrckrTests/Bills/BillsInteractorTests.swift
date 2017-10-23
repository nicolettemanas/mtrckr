//
//  BillsInteractorTests.swift
//  mtrckrTests
//
//  Created by User on 8/17/17.
//

import UIKit
import Nimble
import Quick
import RealmSwift
@testable import mtrckr

class BillsInteractorTests: QuickSpec {
    override func spec() {
        let identifier = "BillsInteractorTests"
        
        let fakeModels = FakeModels()
        var realm: Realm!
        var interactor: BillsInteractor!
        
        beforeEach {
            var config = Realm.Configuration()
            config.inMemoryIdentifier = identifier
            realm = try? Realm(configuration: config)
            try! realm.write {
                realm.deleteAll()
            }
            
            interactor = BillsInteractor(with: RealmAuthConfig())
            interactor?.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
            interactor?.realmContainer?.setDefaultRealm(to: .offline)
            
            realm = interactor.realmContainer!.userRealm!
        }
        
        describe("BillsInteractor") {
            context("asked to save a Bill", {
                var bill1: Bill!
                var bill2: Bill!
                var bill3: Bill!
                
                beforeEach {
                    bill1 = fakeModels.bill()
                    bill2 = fakeModels.bill()
                    bill3 = fakeModels.bill()
                    
                    bill2.startDate = Date().add(1.months)
                    bill3.startDate = Date().subtract(2.months)
                }
                
                it("generates and saves corresponding Bill Entries", closure: {
                    interactor.saveBill(bill: bill1)
                    interactor.saveBill(bill: bill2)
                    interactor.saveBill(bill: bill3)
                    
                    let entries1 = BillEntry.all(in: realm, for: bill1)
                    let entries2 = BillEntry.all(in: realm, for: bill2)
                    let entries3 = BillEntry.all(in: realm, for: bill3)
                    
                    expect(entries1.count) == 1
                    expect(entries2.count) == 1
                    expect(entries3.count) == 3
                    
                    expect(entries1[0].dueDate) == bill1.startDate.start(of: .day)
                    expect(entries2[0].dueDate) == bill2.startDate.start(of: .day)
                    expect(entries3[0].dueDate) == bill3.startDate.start(of: .day)
                    expect(entries3[1].dueDate) == bill3.startDate.add(1.months).start(of: .day)
                    expect(entries3[2].dueDate) == bill3.startDate.add(2.months).start(of: .day)
                })
            })
            
            context("asked to pay a Bill Entry and edit a Bill", {
                var billtoEdit: Bill!
                var oldCategory: mtrckr.Category!
                var entryToPay: BillEntry!
                let datePaid = Date()
                var account: Account!
                var id: String!
                
                beforeEach {
                    account = fakeModels.account()
                    account.save(toRealm: realm)
                    billtoEdit = fakeModels.bill()
                    oldCategory = billtoEdit.category
                    billtoEdit.startDate = Date().subtract(2.months)

                    interactor.saveBill(bill: billtoEdit)
                    entryToPay = BillEntry.all(in: realm, for: billtoEdit).first
                    id = entryToPay.id
                    
                    interactor
                        .payEntry(entry   : entryToPay,
                                  amount  : 200,
                                  account : account,
                                  date    : datePaid)

                    let billInDb = Bill.with(key: billtoEdit.id, inRealm: realm)
                    
                    interactor
                        .update(bill        : billInDb!,
                                amount      : 100,
                                name        : "Updated name",
                                post        : BillDueReminder.never,
                                preDue      : BillDueReminder.never,
                                category    : billInDb!.category!,
                                startDate   : billInDb!.startDate,
                                repeatSched : BillRepeatSchedule.monthly)
                }
                
                it("sets status of entry as paid", closure: {
                    let paid = BillEntry.with(key: id, inRealm: realm)
                    expect(paid?.status) == BillEntryStatus.paid.rawValue
                    expect(paid?.datePaid) == datePaid
                })
                
                it("updates values in the database", closure: {
                    let updatedBill = Bill.with(key: billtoEdit.id, inRealm: realm)
                    expect(updatedBill?.amount) == 100
                    expect(updatedBill?.name) == "Updated name"
                    expect(updatedBill?.preDueReminder) == BillDueReminder.never.rawValue
                    expect(updatedBill?.postDueReminder) == billtoEdit.postDueReminder
                    expect(updatedBill?.repeatSchedule) == billtoEdit.repeatSchedule
                    expect(updatedBill?.startDate) == billtoEdit.startDate
                    expect(updatedBill?.category) == billtoEdit.category
                })
                
                it("updates all unpaid entries to the updated values, store in custom properties", closure: {
                    let updatedEntries = BillEntry.all(in: realm, for: billtoEdit)
                    expect(updatedEntries.count) == 3
                    
                    expect(updatedEntries[0].amount) == 200
                    expect(updatedEntries[0].status) == BillEntryStatus.paid.rawValue
                    expect(updatedEntries[0].customName).to(beNil())
                    expect(updatedEntries[0].customPostDueReminder).to(beNil())
                    expect(updatedEntries[0].customPreDueReminder).to(beNil())
                    expect(updatedEntries[0].customCategory).to(beNil())
                    
                    expect(updatedEntries[1].amount) == 100
                    expect(updatedEntries[1].status) == BillEntryStatus.unpaid.rawValue
                    expect(updatedEntries[1].customName) == "Updated name"
                    expect(updatedEntries[1].customPostDueReminder) == BillDueReminder.never.rawValue
                    expect(updatedEntries[1].customPreDueReminder) == BillDueReminder.never.rawValue
                    expect(updatedEntries[1].customCategory) == oldCategory
                    
                    expect(updatedEntries[2].amount) == 100
                    expect(updatedEntries[2].status) == BillEntryStatus.unpaid.rawValue
                    expect(updatedEntries[2].customName) == "Updated name"
                    expect(updatedEntries[2].customPostDueReminder) == BillDueReminder.never.rawValue
                    expect(updatedEntries[2].customPreDueReminder) == BillDueReminder.never.rawValue
                    expect(updatedEntries[2].customCategory) == oldCategory
                })
                
                context("update includes changing of repeat schedule and start date", {
                    var newDate: Date!
                    beforeEach {
                        newDate = Date().subtract(2.weeks)
                        let billInDb = Bill.with(key: billtoEdit.id, inRealm: realm)
                        interactor
                            .update(bill         : billInDb!,
                                    amount       : 100,
                                    name         : "Updated name",
                                    post         : BillDueReminder.never,
                                    preDue       : BillDueReminder.never,
                                    category     : billInDb!.category!,
                                    startDate    : newDate,
                                    repeatSched  : BillRepeatSchedule.weekly)
                    }
                    
                    it("updates dueDate of unpaid entries", closure: {
                        let updated = BillEntry.all(in: realm, for: billtoEdit)
                        expect(updated.count) == 4
                        
                        expect(updated[0].amount) == 200
                        expect(updated[0].status) == BillEntryStatus.paid.rawValue
                        expect(updated[0].customName).to(beNil())
                        expect(updated[0].customPostDueReminder).to(beNil())
                        expect(updated[0].customPreDueReminder).to(beNil())
                        expect(updated[0].customCategory).to(beNil())
                        
                        expect(updated[1].amount) == 100
                        expect(updated[1].status) == BillEntryStatus.unpaid.rawValue
                        expect(updated[1].customName) == "Updated name"
                        expect(updated[1].customPostDueReminder) == BillDueReminder.never.rawValue
                        expect(updated[1].customPreDueReminder) == BillDueReminder.never.rawValue
                        expect(updated[1].customCategory) == oldCategory
                        expect(updated[1].dueDate) == newDate.start(of: .day)
                        
                        expect(updated[2].amount) == 100
                        expect(updated[2].status) == BillEntryStatus.unpaid.rawValue
                        expect(updated[1].customName) == "Updated name"
                        expect(updated[2].customPostDueReminder) == BillDueReminder.never.rawValue
                        expect(updated[2].customPreDueReminder) == BillDueReminder.never.rawValue
                        expect(updated[2].customCategory) == oldCategory
                        expect(updated[2].dueDate) == newDate.add(1.weeks).start(of: .day)
                        
                        expect(updated[3].amount) == 100
                        expect(updated[3].status) == BillEntryStatus.unpaid.rawValue
                        expect(updated[3].customName) == "Updated name"
                        expect(updated[3].customPostDueReminder) == BillDueReminder.never.rawValue
                        expect(updated[3].customPreDueReminder) == BillDueReminder.never.rawValue
                        expect(updated[3].customCategory) == oldCategory
                        expect(updated[3].dueDate) == newDate.add(2.weeks).start(of: .day)
                    })
                })
            })
            
            context("asked to edit a bill entry", {
                var bill: Bill!
                var entrytoEdit: BillEntry!
                let date = Date()
                
                beforeEach {
                    bill = fakeModels.bill()
                    entrytoEdit = fakeModels.billEntry(for: bill, date: date)
                    
                    interactor.saveBill(bill: bill)
                    entrytoEdit = BillEntry.all(in: realm, for: bill).first
                    
                    interactor
                        .update(entry       : entrytoEdit,
                                amount      : 1233,
                                name        : "new name",
                                preDue      : BillDueReminder.twoDays,
                                postDue     : BillDueReminder.twoDays,
                                category    : nil,
                                dueDate     : date)
                }
                
                it("saves updated properties to custom properties if applicable", closure: {
                    let updatedEntry = BillEntry.all(in: realm, for: bill).first
                    expect(updatedEntry?.amount) == 1233
                    expect(updatedEntry?.customName) == "new name"
                    expect(updatedEntry?.customPreDueReminder) == BillDueReminder.twoDays.rawValue
                    expect(updatedEntry?.customPostDueReminder) == BillDueReminder.twoDays.rawValue
                    expect(updatedEntry?.customCategory).to(beNil())
                    expect(updatedEntry?.dueDate) == date
                })
            })
            
            context("asked to skip an entry", {
                var bill: Bill!
                var entry: BillEntry!
                let date = Date()
                
                beforeEach {
                    bill = fakeModels.bill()
                    bill.startDate = Date().subtract(2.months)
                    entry = fakeModels.billEntry(for: bill, date: date)
                    
                    interactor.saveBill(bill: bill)
                    entry = BillEntry.all(in: realm, for: bill).first
                    interactor.skip(entry: entry, date: date)
                }
                
                it("marks the entry as skipped", closure: {
                    let entry = BillEntry.with(key: entry.id, inRealm: realm)
                    expect(entry?.status) == BillEntryStatus.skipped.rawValue
                })
            })
            
            context("asked to delete a bill", {
                context("delete all unpaid bills", {
                    var bill: Bill!
                    var paidEntry: BillEntry!
                    
                    beforeEach {
                        bill = fakeModels.bill()
                        bill.startDate = Date().subtract(2.months)
                        
                        interactor.saveBill(bill: bill)
                        paidEntry = bill.entries.first
                        
                        paidEntry?
                            .pay(amount       : 1230,
                                 description  : "",
                                 fromAccount  : Account(),
                                 datePaid     : Date(),
                                 inRealm      : realm)
                        
                        interactor.delete(bill: bill)
                    }
                    
                    it("tags the bill as inactive and deletes all unpaid entries of the bill", closure: {
                        bill = Bill.with(key: bill.id, inRealm: realm)
                        let entries = BillEntry.allUnpaid(in: realm, for: [bill])
                        paidEntry = BillEntry.with(key: paidEntry.id, inRealm: realm)
                        
                        expect(bill.active) == false
                        expect(entries.count) == 0
                        expect(paidEntry).toNot(beNil())
                    })
                })
                
                context("delete current bill entry", {
                    var bill: Bill!
                    var entryToDelete: BillEntry!
                    
                    beforeEach {
                        bill = fakeModels.bill()
                        bill.startDate = Date().subtract(2.months)
                        
                        interactor.saveBill(bill: bill)
                        entryToDelete = bill.entries.first
                        interactor.delete(billEntry: entryToDelete)
                    }
                    
                    it("deletes the selected bill entry", closure: {
                        let billEntries = BillEntry.all(in: realm, for: bill)
                        expect(billEntries.count) == 2
                    })
                })
            })
        }
    }
}
