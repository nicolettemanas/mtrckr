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
        
        var fakeModels: FakeModels!
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
            
            fakeModels = FakeModels()
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
            
            context("asked to edit a Bill", {
                var billtoEdit: Bill!
                var oldCategory: mtrckr.Category!
                
                beforeEach {
                    billtoEdit = fakeModels.bill()
                    oldCategory = billtoEdit.category
                    billtoEdit.startDate = Date().subtract(2.months)
                    // save bill
                    interactor.saveBill(bill: billtoEdit)
                    let firstEntry = BillEntry.all(in: realm, for: billtoEdit).first
                    // pay first entry
                    firstEntry?.pay(amount: 200, description: "", fromAccount: Account(),
                                    datePaid: Date(), inRealm: realm)

                    let billInDb = Bill.with(key: billtoEdit.id, inRealm: realm)
                    interactor.update(bill: billInDb!, amount: 100, name: "Updated name",
                                      postDueReminder: BillDueReminder.never,
                                      preDueReminder: BillDueReminder.never,
                                      category: billInDb!.category!,
                                      startDate: billInDb!.startDate,
                                      repeatSchedule: BillRepeatSchedule.monthly)
                }
                
                it("updates values in the database", closure: {
                    let updatedBill = Bill.with(key: billtoEdit.id, inRealm: realm)
                    expect(updatedBill?.amount) == 100
                    expect(updatedBill?.preDueReminder) == BillDueReminder.never.rawValue
                    expect(updatedBill?.name) == "Updated name"
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
                        interactor.update(bill: billInDb!, amount: 100, name: "Updated name",
                                          postDueReminder: BillDueReminder.never,
                                          preDueReminder: BillDueReminder.never,
                                          category: billInDb!.category!,
                                          startDate: newDate,
                                          repeatSchedule: BillRepeatSchedule.weekly)
                    }
                    
                    it("updates dueDate of unpaid entries", closure: {
                        let updatedEntries = BillEntry.all(in: realm, for: billtoEdit)
                        expect(updatedEntries.count) == 4
                        
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
                        expect(updatedEntries[1].dueDate) == newDate.start(of: .day)
                        
                        expect(updatedEntries[2].amount) == 100
                        expect(updatedEntries[2].status) == BillEntryStatus.unpaid.rawValue
                        expect(updatedEntries[1].customName) == "Updated name"
                        expect(updatedEntries[2].customPostDueReminder) == BillDueReminder.never.rawValue
                        expect(updatedEntries[2].customPreDueReminder) == BillDueReminder.never.rawValue
                        expect(updatedEntries[2].customCategory) == oldCategory
                        expect(updatedEntries[2].dueDate) == newDate.add(1.weeks).start(of: .day)
                        
                        expect(updatedEntries[3].amount) == 100
                        expect(updatedEntries[3].status) == BillEntryStatus.unpaid.rawValue
                        expect(updatedEntries[3].customName) == "Updated name"
                        expect(updatedEntries[3].customPostDueReminder) == BillDueReminder.never.rawValue
                        expect(updatedEntries[3].customPreDueReminder) == BillDueReminder.never.rawValue
                        expect(updatedEntries[3].customCategory) == oldCategory
                        expect(updatedEntries[3].dueDate) == newDate.add(2.weeks).start(of: .day)
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
                    
                    interactor.updateBillEntry(entry: entrytoEdit, amount: 1233, name: "new name",
                                               preDueReminder: BillDueReminder.twoDays,
                                               postDueReminder: BillDueReminder.twoDays,
                                               category: nil, dueDate: date)
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
            
            context("asked to delete a bill", {
                context("delete all future bills", {
                    
                })
                
                context("delete all bills", {
                    
                })
            })
        }
    }
}
