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
        var resolver: ViewControllerResolvers!
        var stubResolver: StubViewControllerResolvers!
        var mockInteractor: MockBillsInteractor?
        let fakeModels = FakeModels()
        
        beforeEach {
            resolver = ViewControllerResolvers()
            stubResolver = StubViewControllerResolvers()
            
            presenter = resolver.container.resolve(BillsPresenter.self)
            mockInteractor = stubResolver.container.resolve(BillsInteractor.self, name: "mock") as? MockBillsInteractor
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
                    presenter.createBill(amount: 120.0, name: "Create new bill", post: BillDueReminder.onDate.rawValue,
                                         pre: BillDueReminder.oneDay.rawValue, repeatSchedule: BillRepeatSchedule.never.rawValue,
                                         startDate: date, category: category)
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
            
            context("deleting a bill entry", {
                context("delete only current bill", {
                    it("asks interactor to delete current bill", closure: {
                        presenter.deleteBillEntry(entry: billEntry, deleteType: ModifyBillType.currentBill)
                        expect(mockInteractor?.didDeleteBill) == billEntry
                        expect(mockInteractor?.deleteType) == .currentBill
                    })
                })

                context("delete all proceeding bills", {
                    it("asks interactor to delete proceeding bills", closure: {
                        presenter.deleteBillEntry(entry: billEntry, deleteType: ModifyBillType.allBills)
                        expect(mockInteractor?.didDeleteBill) == billEntry
                        expect(mockInteractor?.deleteType) == .allBills
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
                        
                        presenter.editBillEntry(billEntry: entryToUpdate, amount: 999, name: "New Bill Name",
                                                post: BillDueReminder.threeDays.rawValue, pre: BillDueReminder.twoDays.rawValue,
                                                startDate: date, category: cat)

                        expect(mockInteractor?.newEntry?.amount) == 999
                        expect(mockInteractor?.newEntry?.dueDate) == date.start(of: .day)
                        expect(mockInteractor?.newEntry?.customName) == "New Bill Name"
                        expect(mockInteractor?.newEntry?.customPostDueReminder) == BillDueReminder.threeDays.rawValue
                        expect(mockInteractor?.newEntry?.customPreDueReminder) == BillDueReminder.twoDays.rawValue
                        expect(mockInteractor?.newEntry?.customCategory) == cat
                    })
                })
                context("update all proceeding bill entries", {
                    it("passes consolidated values to interactor", closure: {
                        let bill = fakeModels.bill()
                        let cat = fakeModels.category()
                        let date = Date().add(2.days)
                        let proceedingDAte = Date()
                        
                        presenter.editBillAndEntries(bill: bill, amount: 999, name: "New Bill Name",
                                                     post: BillDueReminder.threeDays.rawValue, pre: BillDueReminder.twoDays.rawValue,
                                                     repeatSchedule: BillRepeatSchedule.never.rawValue,
                                                     startDate: date, category: cat, proceedingDate: proceedingDAte)

                        expect(mockInteractor?.updatedBill?.amount) == 999
                        expect(mockInteractor?.updatedBill?.startDate) == date
                        expect(mockInteractor?.updatedBill?.name) == "New Bill Name"
                        expect(mockInteractor?.updatedBill?.postDueReminder) == BillDueReminder.threeDays.rawValue
                        expect(mockInteractor?.updatedBill?.preDueReminder) == BillDueReminder.twoDays.rawValue
                        expect(mockInteractor?.updatedBill?.repeatSchedule) == BillRepeatSchedule.never.rawValue
                        expect(mockInteractor?.updatedBill?.category) == cat
                    })
                })
            })
        }
    }
}
