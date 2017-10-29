//
//  NewBillPresenterTests.swift
//  mtrckrTests
//
//  Created by User on 9/5/17.
//

import UIKit
import Nimble
import Quick
@testable import mtrckr

class NewBillViewControllerTests: QuickSpec {
    override func spec() {
        var newBillViewController: NewBillViewController?
        var billsViewController: (MockBillsTableViewController & NewBillViewControllerDelegate)?

        let resolver = MTResolver()
        let fakeModels = FakeModels()

        beforeEach {
            billsViewController = MockBillsTableViewController()
            newBillViewController = resolver.container
                .resolve(NewBillViewController.self,
                         arguments: billsViewController as! NewBillViewControllerDelegate,
                         nil as BillEntry?)
            newBillViewController?.action = MockAlertAction.self

            expect(newBillViewController?.delegate).toNot(beNil())
            expect(newBillViewController?.view).toNot(beNil())
        }

        describe("saving changes") {
            context("if form is presented to create a new bill", {
                let date = Date()
                let cat = fakeModels.category()
                
                context("if some fields are left empty", {
                    beforeEach {
                        newBillViewController?.didPressSave()
                    }
                    
                    it("will not proceed saving", closure: {
                        expect(billsViewController?.didSave) == false
                    })
                })

                context("all required fields are validated", {
                    beforeEach {
                        newBillViewController?.nameRow.value = "My new bill"
                        newBillViewController?.amountRow.value = 1500
                        newBillViewController?.dueDateRow.value = date
                        newBillViewController?.repeatRow.value = BillRepeatSchedule.weekly.rawValue
                        newBillViewController?.preRow.value = BillDueReminder.threeDays.rawValue
                        newBillViewController?.postRow.value = BillDueReminder.oneWeek.rawValue
                        newBillViewController?.categoryRow.value = cat
                        newBillViewController?.didPressSave()
                    }
                    
                    it("returns values to delegate and proceed creating bill", closure: {
                        expect(billsViewController?.didSave) == true
                        expect(billsViewController?.amount) == 1500
                        expect(billsViewController?.name) == "My new bill"
                        expect(billsViewController?.post) == BillDueReminder.oneWeek.rawValue
                        expect(billsViewController?.pre) == BillDueReminder.threeDays.rawValue
                        expect(billsViewController?.repeatSchedule) == BillRepeatSchedule.weekly.rawValue
                        expect(billsViewController?.startDate) == date
                        expect(billsViewController?.category) == cat
                    })
                })
            })

            context("if form is presented to edit a bill/entry", {
                var bill: Bill!
                var billEntry: BillEntry!
                let date = Date()
                let cat = fakeModels.category()

                beforeEach {
                    bill = fakeModels.bill()
                    billEntry = fakeModels.billEntry(for: bill, date: Date())
                    newBillViewController?.billEntry = billEntry
                }
                
                context("if some fields are left empty", {
                    it("will not show confirmatioin sheet", closure: {
                        newBillViewController?.didPressSave()
                        expect(newBillViewController?.alert).to(beNil())
                    })
                })

                context("all required fields are validated", {
                    beforeEach {
                        newBillViewController?.nameRow.value = "My new bill"
                        newBillViewController?.amountRow.value = 1500
                        newBillViewController?.dueDateRow.value = date
                        newBillViewController?.repeatRow.value = BillRepeatSchedule.weekly.rawValue
                        newBillViewController?.preRow.value = BillDueReminder.threeDays.rawValue
                        newBillViewController?.postRow.value = BillDueReminder.oneWeek.rawValue
                        newBillViewController?.categoryRow.value = cat
                        newBillViewController?.didPressSave()
                    }
                    
                    it("displays confirmation sheet", closure: {
                        expect(newBillViewController?.alert).toNot(beNil())
                    })
                    
                    context("if chooses to edit only current bill entry", {
                        beforeEach {
                            let controller = newBillViewController?.alert
                            let currentBillAction = controller!.actions[1] as! MockAlertAction
                            currentBillAction.mockHandler!(currentBillAction)
                        }
                        
                        it("returns values and billEntry to update", closure: {
                            expect(billsViewController?.didEditBillEntry) == billEntry
                            expect(billsViewController?.amount) == 1500
                            expect(billsViewController?.name) == "My new bill"
                            expect(billsViewController?.post) == BillDueReminder.oneWeek.rawValue
                            expect(billsViewController?.pre) == BillDueReminder.threeDays.rawValue
                            expect(billsViewController?.repeatSchedule) == BillRepeatSchedule.weekly.rawValue
                            expect(billsViewController?.startDate) == date
                            expect(billsViewController?.category) == cat
                        })
                    })
                    
                    context("chooses to edit all unpaid bill entries", {
                        beforeEach {
                            let controller = newBillViewController?.alert
                            let allBillAction = controller!.actions[2] as! MockAlertAction
                            allBillAction.mockHandler!(allBillAction)
                        }
                        
                        it("returns values and bill to update", closure: {
                            expect(billsViewController?.didEditBill) == bill
                            expect(billsViewController?.amount) == 1500
                            expect(billsViewController?.name) == "My new bill"
                            expect(billsViewController?.post) == BillDueReminder.oneWeek.rawValue
                            expect(billsViewController?.pre) == BillDueReminder.threeDays.rawValue
                            expect(billsViewController?.repeatSchedule) == BillRepeatSchedule.weekly.rawValue
                            expect(billsViewController?.startDate) == date
                            expect(billsViewController?.category) == cat
                        })
                    })
                })
            })
        }
    }
}
