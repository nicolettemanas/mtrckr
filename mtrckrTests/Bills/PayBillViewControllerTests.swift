//
//  PayBillViewControllerTests.swift
//  mtrckrTests
//
//  Created by User on 10/15/17.
//

import UIKit
import Nimble
import Quick
@testable import mtrckr

class PayBillViewControllerTests: QuickSpec {
    override func spec() {
        
        var payBillVC: PayBillViewController?
        var billsVC: MockBillsTableViewController?
        
        let resolver = MTResolver()
        let fakeModels = FakeModels()
        
        let bill = fakeModels.bill()
        let entryToPay = fakeModels.billEntry(for: bill, date: Date())
        
        beforeEach {
            billsVC = MockBillsTableViewController()
            payBillVC = resolver.container
                .resolve(PayBillViewController.self,
                         arguments: entryToPay,
                         billsVC as! PayBillViewControllerDelegate)
            
            expect(payBillVC?.delegate).toNot(beNil())
            expect(payBillVC?.view).toNot(beNil())
        }
        
        describe("submitting a payment") {
            context("if some fields are left empty", {
                beforeEach {
                    payBillVC?.didPressPayBill()
                }
                
                it("will not proceed payment", closure: {
                    expect(billsVC?.didPay) == false
                })
            })
            
            context("all required fields are validated", {
                let account = fakeModels.account()
                let datePaid = Date()
                
                beforeEach {
                    payBillVC?.accountRow.value = account
                    payBillVC?.payRow.value = 1000
                    payBillVC?.dateRow.value = datePaid
                    payBillVC?.didPressPayBill()
                }
                
                it("returns values to delegate", closure: {
                    expect(billsVC?.didPayAmount) == 1000
                    expect(billsVC?.didPayAccount) == account
                    expect(billsVC?.didPayDate) == datePaid
                })
            })
        }
    }
}
