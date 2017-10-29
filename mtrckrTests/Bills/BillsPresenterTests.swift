//
//  BillsPresenterTests.swift
//  mtrckrTests
//
//  Created by User on 8/25/17.
//

import UIKit
import Quick
import Nimble
@testable import mtrckr

class BillsPresenterTests: QuickSpec {
    override func spec() {
        
        var presenter: BillsPresenterProtocol!
        var resolver: MTResolver!
        var stubResolver: StubMTResolvers!
        var mockInteractor: MockBillsInteractor?
        let fakeModels = FakeModels()
        
        beforeEach {
            resolver = MTResolver()
            stubResolver = StubMTResolvers()
            
            presenter = resolver.container
                .resolve(BillsPresenter.self)
            mockInteractor = stubResolver.container
                .resolve(BillsInteractor.self, name: "mock") as? MockBillsInteractor
            
            presenter.interactor = mockInteractor
        }
        
        describe("BillsPresenter") {
            var billEntry: BillEntry!
            
            beforeEach {
                let bill = fakeModels.bill()
                billEntry = fakeModels.billEntry(for: bill, date: Date())
            }

            context("saving a bill", {
                let date = Date()
                let category = fakeModels.category()
                
                beforeEach {
                    presenter
                        .createBill(amount      : 120.0,
                                    name        : "Create new bill",
                                    post        : BillDueReminder.onDate.rawValue,
                                    pre         : BillDueReminder.oneDay.rawValue,
                                    repeat      : BillRepeatSchedule.never.rawValue,
                                    startDate   : date,
                                    category    : category)
                }
                it("passes consolidated Bill to interactor", closure: {
                    expect(mockInteractor?.createdBill?.amount) == 120
                    expect(mockInteractor?.createdBill?.name) == "Create new bill"
                    expect(mockInteractor?.createdBill?.postDueReminder) == BillDueReminder.onDate.rawValue
                    expect(mockInteractor?.createdBill?.preDueReminder) == BillDueReminder.oneDay.rawValue
                    expect(mockInteractor?.createdBill?.repeatSchedule) == BillRepeatSchedule.never.rawValue
                    expect(mockInteractor?.createdBill?.startDate) == date
                    expect(mockInteractor?.createdBill?.category) == category
                })
            })
            
            context("paying a bill", {
                let date = Date()
                let account = fakeModels.account()
                let bill = fakeModels.bill()
                let entry = fakeModels.billEntry(for: bill, date: date)
                
                beforeEach {
                    presenter
                        .payEntry(entry     : entry,
                                  amount    : 1000,
                                  account   : account,
                                  date      : date)
                }

                it("passes billEntry to pay to interactor", closure: {
                    expect(mockInteractor?.entryToPay) == entry
                    expect(mockInteractor?.payAccount) == account
                    expect(mockInteractor?.payAmount) == 1000
                    expect(mockInteractor?.payDate) == date
                })
            })
            
            context("skipping an entry", {
                let bill = fakeModels.bill()
                let entry = fakeModels.billEntry(for: bill, date: Date())
                beforeEach {
                    presenter.skip(entry: entry)
                }
                it("passes entry to skip to interactor", closure: {
                    expect(mockInteractor?.entryToSkip) == entry
                })
            })
            
            context("deleting a bill entry", {
                context("delete only current bill", {
                    it("asks interactor to delete current bill", closure: {
                        presenter.deleteBillEntry(entry: billEntry, deleteType: ModifyBillType.currentBill)
                        expect(mockInteractor?.didDeleteBillEntry) == billEntry
                    })
                })

                context("delete all unpaid bills", {
                    it("asks interactor to delete unpaid bills", closure: {
                        presenter.deleteBillEntry(entry: billEntry, deleteType: ModifyBillType.allBills)
                        expect(mockInteractor?.didDeleteBill) == billEntry.bill
                    })
                })
            })
            
            context("updating a bill", {
                context("updating only the current entry", {
                    it("passes consolidated values to interactor", closure: {
                        let bill = fakeModels.bill()
                        let cat = fakeModels.category()
                        let date = Date().add(2.days)
                        let entryToUpdate = fakeModels.billEntry(for: bill, date: Date())
                        
                        presenter
                            .editBillEntry(billEntry    : entryToUpdate,
                                           amount       : 999,
                                           name         : "New Bill Name",
                                           post         : BillDueReminder.threeDays.rawValue,
                                           pre          : BillDueReminder.twoDays.rawValue,
                                           startDate    : date,
                                           category     : cat)

                        expect(mockInteractor?.updatedAmount) == 999
                        expect(mockInteractor?.updatedDate) == date
                        expect(mockInteractor?.updatedName) == "New Bill Name"
                        expect(mockInteractor?.updatedPost) == BillDueReminder.threeDays
                        expect(mockInteractor?.updatedPre) == BillDueReminder.twoDays
                        expect(mockInteractor?.updatedCat) == cat
                    })
                })
                context("update all unpaid bill entries", {
                    it("passes consolidated values to interactor", closure: {
                        let bill = fakeModels.bill()
                        let cat = fakeModels.category()
                        let date = Date().add(2.days)
                        
                        presenter
                            .editBillAndEntries(bill        : bill,
                                                amount      : 999,
                                                name        : "New Bill Name",
                                                post        : BillDueReminder.threeDays.rawValue,
                                                pre         : BillDueReminder.twoDays.rawValue,
                                                repeat      : BillRepeatSchedule.never.rawValue,
                                                startDate   : date,
                                                category    : cat)

                        expect(mockInteractor?.billToUpdate) == bill
                        expect(mockInteractor?.updatedAmount) == 999
                        expect(mockInteractor?.updatedDate) == date
                        expect(mockInteractor?.updatedName) == "New Bill Name"
                        expect(mockInteractor?.updatedPost) == BillDueReminder.threeDays
                        expect(mockInteractor?.updatedPre) == BillDueReminder.twoDays
                        expect(mockInteractor?.updatedRepeat) == BillRepeatSchedule.never
                        expect(mockInteractor?.updatedCat) == cat
                    })
                })
            })
        }
    }
}
