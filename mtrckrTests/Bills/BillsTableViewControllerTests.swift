//
//  BillsTableViewControllerTests.swift
//  mtrckrTests
//
//  Created by User on 8/15/17.
//

import UIKit
import Nimble
import Quick
import RealmSwift
@testable import mtrckr

class BillsTableViewControllerTests: QuickSpec {
    override func spec() {
        var billsViewController: BillsTableViewController!
        var mockNewBillPresenter: MockNewBillPresenter?
        var mockDeleteBillPresenter: MockDeleteBillPresenter?
        var billInteractor: BillsInteractorProtocol?
        var mockPresenter: MockBillsPresenter?
        var realm: Realm!
        let fakeModels = FakeModels()

        let identifier = "BillsTableViewControllerTests"

        beforeEach {
            let resolvers = ViewControllerResolvers()
            let mockResolvers = StubViewControllerResolvers()

            mockNewBillPresenter = mockResolvers.container.resolve(NewBillPresenter.self, name: "mock") as? MockNewBillPresenter
            mockDeleteBillPresenter = mockResolvers.container.resolve(DeleteBillPresenter.self, name: "mock") as? MockDeleteBillPresenter
            billInteractor = mockResolvers.container.resolve(BillsInteractor.self, name: "stub", argument: identifier)
            mockPresenter = mockResolvers.container.resolve(BillsPresenter.self, name: "mock") as? MockBillsPresenter

            billsViewController = resolvers.container.resolve(BillsTableViewController.self)
            billsViewController.newBillPresenter = mockNewBillPresenter
            billsViewController.deleteBillPresenter = mockDeleteBillPresenter
            billsViewController.dataSource = mockResolvers.container.resolve(BillsDataSource.self, name: "mock", argument: identifier)
            billsViewController.dataSource?.delegate = billsViewController
            billsViewController.presenter = mockPresenter
            expect(billsViewController.view).toNot(beNil())

            realm = (billInteractor as! BillsInteractor).realmContainer!.userRealm!
            try! realm.write {
                realm.deleteAll()
            }
        }

        describe("BillsTableViewController") {
            beforeEach {
                billInteractor?.saveBill(bill: fakeModels.bill())
                billInteractor?.saveBill(bill: fakeModels.bill())
                billInteractor?.saveBill(bill: fakeModels.bill())

                billsViewController.dataSource?.refresh()
            }

            context("Taps + button to create a bill", {
                it("Presents new bill form") {
                    billsViewController.createBillbtnPressed(sender: nil)
                    expect(mockNewBillPresenter?.didPresent) == true
                    expect(mockNewBillPresenter?.didReceiveId).to(beNil())
                }

                context("receives new values", {
                    it("pass values to presenter", closure: {
                        let date = Date()
                        let cat = fakeModels.category()
                        billsViewController.saveNewBill(amount: 100, name: "New Bill", post: BillDueReminder.never.rawValue,
                                                        pre: BillDueReminder.onDate.rawValue, repeatSchedule: BillRepeatSchedule.weekly.rawValue,
                                                        startDate: date, category: cat)
                        expect(mockPresenter?.didCreate) == true
                        expect(mockPresenter?.didCreateAmount) == 100
                        expect(mockPresenter?.didCreateName) == "New Bill"
                        expect(mockPresenter?.didCreatePost) == BillDueReminder.never.rawValue
                        expect(mockPresenter?.didCreatePre) == BillDueReminder.onDate.rawValue
                        expect(mockPresenter?.didCreateRepeat) == BillRepeatSchedule.weekly.rawValue
                        expect(mockPresenter?.didCreateStartDate) == date
                        expect(mockPresenter?.didCreateCategory) == cat
                    })
                })
            })

            context("chooses to edit the first BillEntry displayed", {
                beforeEach {
                    billsViewController.editBillEntry(atIndex: IndexPath(item: 0, section: 0))
                }

                it("presents edit form", closure: {
                    let index = IndexPath(row: 0, section: 0)
                    billsViewController.editBillEntry(atIndex: index)
                    expect(mockNewBillPresenter?.didPresent) == true
                    expect(mockNewBillPresenter?.didReceiveId) == billsViewController.dataSource?.entry(at: index)?.id
                })

                context("receives edited values/confirm to edit", {
                    context("edit current bill entry", {
                        let date = Date()
                        let bill = fakeModels.bill()
                        let entryToEdit = fakeModels.billEntry(for: bill, date: date)
                        let cat = fakeModels.category()

                        beforeEach {
                            billsViewController.edit(billEntry: entryToEdit, amount: 99.0, name: "New Entry Name",
                                                     post: BillDueReminder.never.rawValue, pre: BillDueReminder.onDate.rawValue,
                                                     repeatSchedule: BillRepeatSchedule.weekly.rawValue, startDate: date, category: cat)
                        }

                        it("passes values to edit to presenter", closure: {
                            expect(mockPresenter?.didEdit) == true
                            expect(mockPresenter?.didEditEntry) == entryToEdit
                            expect(mockPresenter?.didEditEntryAmount) == 99.0
                            expect(mockPresenter?.didEditEntryName) == "New Entry Name"
                            expect(mockPresenter?.didEditEntryPost) == BillDueReminder.never.rawValue
                            expect(mockPresenter?.didEditEntryPre) == BillDueReminder.onDate.rawValue
                            expect(mockPresenter?.didEditEntryStartDate) == date
                            expect(mockPresenter?.didEditEntryCategory) == cat
                        })
                    })

                    context("for edit all proceeding bills", {
                        let date = Date().subtract(1.days)
                        let proceedingDate = Date()
                        let bill = fakeModels.bill()
                        let cat = fakeModels.category()
                        beforeEach {
                            billsViewController.edit(bill: bill, amount: 99.0, name: "New Bill",
                                                     post: BillDueReminder.never.rawValue, pre: BillDueReminder.onDate.rawValue,
                                                     repeatSchedule: BillRepeatSchedule.weekly.rawValue, startDate: date,
                                                     category: cat, proceedingDate: proceedingDate)
                        }

                        it("passes values to edit to presenter", closure: {
                            expect(mockPresenter?.didEdit) == true
                            expect(mockPresenter?.didEditBill) == bill
                            expect(mockPresenter?.didEditBillAmount) == 99.0
                            expect(mockPresenter?.didEditBillName) == "New Bill"
                            expect(mockPresenter?.didEditBillPost) == BillDueReminder.never.rawValue
                            expect(mockPresenter?.didEditBillPre) == BillDueReminder.onDate.rawValue
                            expect(mockPresenter?.didEditBillRepeatSchedule) == BillRepeatSchedule.weekly.rawValue
                            expect(mockPresenter?.didEditBillStartDate) == date
                            expect(mockPresenter?.didEditBillCategory) == cat
                            expect(mockPresenter?.didEditBillProceedingDate) == proceedingDate
                        })
                    })
                })
            })

            context("chooses to delete the first BillEntry displayed", {
                let indexToDelete = IndexPath(row: 0, section: 0)
                beforeEach {
                    billsViewController.deleteBillEntry(atIndex: indexToDelete)
                }

                it("Displays delete action sheet options", closure: {
                    let controller: UIAlertController? = billsViewController!.deleteBillPresenter!.alert
                    expect(controller).toNot(beNil())
                    expect(mockDeleteBillPresenter!.didPresentDeleteSheet) == true
                    expect(mockDeleteBillPresenter?.billEntryToDelete) == billsViewController.dataSource?.entry(at: indexToDelete)
                })

                context("user chooses to delete bill entry", {
                    var entry: BillEntry!

                    beforeEach {
                        entry = billsViewController.dataSource?.entry(at: indexToDelete)
                    }

                    context("only delete current entry", {
                        it("tells presenter to delete the current bill entry", closure: {
                            let controller: UIAlertController = billsViewController!.deleteBillPresenter!.alert!
                            let deleteAction = controller.actions[1] as! MockAlertAction
                            deleteAction.mockHandler!(deleteAction)

                            expect(mockPresenter?.didDelete) == true
                            expect(mockPresenter?.didDeleteEntry) == entry
                            expect(mockPresenter?.deleteType) == .currentBill
                        })
                    })

                    context("delete all proceeding entries", {
                        it("tells presenter to delete all proceeding bills", closure: {
                            let controller: UIAlertController = billsViewController!.deleteBillPresenter!.alert!
                            let deleteAction = controller.actions[2] as! MockAlertAction
                            deleteAction.mockHandler!(deleteAction)

                            expect(mockPresenter?.didDelete) == true
                            expect(mockPresenter?.didDeleteEntry) == entry
                            expect(mockPresenter?.deleteType) == .allBills
                        })
                    })
                })

                context("user chooses to cancel deletion", {

                })
            })

            context("user taps a bill entry", {
                it("presents its payment history", closure: {
                    let index = IndexPath(row: 0, section: 0)
                    billsViewController.dataSource!.tableView!(billsViewController.tableView, didSelectRowAt: index)
                    let entry = billsViewController.dataSource?.entry(at: index)
                    expect(mockPresenter?.didShowHistory) == true
                    expect(mockPresenter?.didShowHistoryOf) == entry
                })
            })

            context("user taps 'pay' on an unpaid bill", {
                it("presents form to create transaction with pre-filled values", closure: {
                    let index = IndexPath(row: 0, section: 0)
                    let cell: BillsCell = billsViewController.dataSource!
                        .tableView(billsViewController.tableView,
                                   cellForRowAt: index) as! BillsCell
                    cell.payButtonDidPress(sender: cell.payButton)
                    let entry = billsViewController.dataSource?.entry(at: index)
                    expect(mockPresenter?.didPayBill) == true
                    expect(mockPresenter?.didPayBillEntry) == entry
                })
            })
        }
    }
}
