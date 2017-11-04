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
        var mockBillVCPresenter: MockBillVCPresenter?
        var mockDeleteBillPresenter: MockDeleteBillPresenter?
        var billInteractor: BillsInteractorProtocol?
        var mockPresenter: MockBillsPresenter?
        var realm: Realm!
        let fakeModels = FakeModels()

        let identifier = "BillsTableViewControllerTests"

        beforeEach {
            let resolvers = MTResolver()
            let mockResolvers = StubMTResolvers()

            mockBillVCPresenter = mockResolvers.container
                .resolve(BillVCPresenter.self, name: "mock") as? MockBillVCPresenter
            mockDeleteBillPresenter = mockResolvers.container
                .resolve(DeleteBillPresenter.self, name: "mock") as? MockDeleteBillPresenter
            billInteractor = mockResolvers.container
                .resolve(BillsInteractor.self, name: "stub", argument: identifier)
            mockPresenter = mockResolvers.container
                .resolve(BillsPresenter.self, name: "mock") as? MockBillsPresenter
            billsViewController = resolvers.container
                .resolve(BillsTableViewController.self)
            billsViewController.dataSource = mockResolvers.container
                .resolve(BillsDataSource.self, name: "mock", argument: identifier)
            
            billsViewController.billVCPresenter = mockBillVCPresenter
            billsViewController.deleteBillPresenter = mockDeleteBillPresenter
            billsViewController.dataSource?.delegate = billsViewController
            billsViewController.presenter = mockPresenter

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

                expect(billsViewController.view).toNot(beNil())
            }

            context("Taps + button to create a bill", {
                it("Presents new bill form") {
                    billsViewController.createBillbtnPressed(sender: nil)
                    expect(mockBillVCPresenter?.didPresent) == true
                    expect(mockBillVCPresenter?.didReceiveId).to(beNil())
                }

                context("receives new values", {
                    it("pass values to presenter", closure: {
                        let date = Date()
                        let cat = fakeModels.category()
                        billsViewController
                            .saveNewBill(amount         : 100,
                                         name           : "New Bill",
                                         post            : BillDueReminder.never.rawValue,
                                         pre            : BillDueReminder.onDate.rawValue,
                                         repeat : BillRepeatSchedule.weekly.rawValue,
                                         startDate      : date, category: cat)
                        
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
                    expect(mockBillVCPresenter?.didPresent) == true
                    expect(mockBillVCPresenter?.didReceiveId) == billsViewController.dataSource?.entry(at: index)?.id
                })

                context("receives edited values/confirm to edit", {
                    context("edit current bill entry", {
                        let date = Date()
                        let bill = fakeModels.bill()
                        let entryToEdit = fakeModels.billEntry(for: bill, date: date)
                        let cat = fakeModels.category()

                        beforeEach {
                            billsViewController
                                .edit(billEntry         : entryToEdit,
                                      amount            : 99.0,
                                      name              : "New Entry Name",
                                      post              : BillDueReminder.never.rawValue,
                                      pre               : BillDueReminder.onDate.rawValue,
                                      repeatSchedule    : BillRepeatSchedule.weekly.rawValue,
                                      startDate         : date,
                                      category          : cat)
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

                    context("for edit all unpaid bills", {
                        let date = Date().subtract(1.days)
                        let bill = fakeModels.bill()
                        let cat = fakeModels.category()
                        beforeEach {
                            billsViewController
                                .edit(bill	            : bill,
                                      amount            : 99.0,
                                      name              : "New Bill",
                                      post	            : BillDueReminder.never.rawValue,
                                      pre               : BillDueReminder.onDate.rawValue,
                                      repeatSchedule    : BillRepeatSchedule.weekly.rawValue,
                                      startDate	        : date,
                                      category	        : cat)
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

                    context("delete all unpaid entries", {
                        it("tells presenter to delete all unpaid bills", closure: {
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
                    billsViewController.dataSource!
                        .tableView!(billsViewController.tableView, didSelectRowAt: index)
                    
                    let entry = billsViewController.dataSource?.entry(at: index)
                    expect(mockBillVCPresenter?.didShowHistory) == true
                    expect(mockBillVCPresenter?.didShowHistoryOf) == entry?.bill
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
                    
                    expect(mockBillVCPresenter?.didPresent) == true
                    expect(mockBillVCPresenter?.didReceiveId) == entry?.id
                })
            })
            
            context("user confirms paying an entry", {
                let date = Date()
                let bill = fakeModels.bill()
                let entry = fakeModels.billEntry(for: bill, date: date)
                let account = fakeModels.account()
                
                beforeEach {
                    billsViewController
                        .proceedPayment(ofBill   : entry,
                                        amount   : 120,
                                        account  : account,
                                        date     : date)
                }
                
                it("passes values to presenter", closure: {
                    expect(mockPresenter?.didPayBillEntry) == entry
                    expect(mockPresenter?.didPayAccount) == account
                    expect(mockPresenter?.didPayAmount) == 120
                    expect(mockPresenter?.didPayDate) == date
                })
            })
            
            context("user skips a bill entry", {
                let firstIndex = IndexPath(row: 0, section: 0)
                var entry: BillEntry!
                beforeEach {
                    billsViewController.skipBillEntry(atIndex: firstIndex)
                    entry = billsViewController.dataSource?.entry(at: firstIndex)
                }
                
                it("tells presenter to skip entry", closure: {
                    expect(mockPresenter?.didSkipEntry) == entry
                })
            })
        }
    }
}
