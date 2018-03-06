//
//  NewAccountFormVC.swift
//  mtrckrTests
//
//  Created by User on 11/13/17.
//

import UIKit
import Quick
import Nimble
@testable import mtrckr

class NewAccountFormVCTests: QuickSpec {
    override func spec() {
        var newAccountVC: NewAccountFormVC?
        var mockAccountsVC: MockAccountsTableViewController?
        
        let fakeModels = FakeModels()
        var account: Account?
        
        beforeEach {
            mockAccountsVC = MockAccountsTableViewController()
            newAccountVC = StubMTResolvers.shared.container
                .resolve(NewAccountFormVC.self, name: "testable", argument: account)!
            newAccountVC?.delegate = mockAccountsVC
            expect(newAccountVC?.view).toNot(beNil())
            expect(mockAccountsVC).toNot(beNil())
        }
        
        describe("saving changes") {
            context("if form is presented to create a new account", {
                context("if some text fields are left empty", {
                    beforeEach {
                        _ = newAccountVC?.perform(newAccountVC?.navigationItem.rightBarButtonItem?.action)
                    }
                    
                    it("will not proceed saving", closure: {
                        expect(mockAccountsVC).toNot(beNil())
                        expect(mockAccountsVC?.didCreate) == false
                        expect(mockAccountsVC?.createdName).to(beNil())
                        expect(mockAccountsVC?.createdType).to(beNil())
                        expect(mockAccountsVC?.createdBalance).to(beNil())
                        expect(mockAccountsVC?.createdDate).to(beNil())
                        expect(mockAccountsVC?.createdColor).to(beNil())
                    })
                })
                
                context("if all required fields are validated", {
                    var type: AccountType?
                    var date: Date?
                    
                    beforeEach {
                        type = fakeModels.accountType(id: 129)
                        date = Date()
                        
                        newAccountVC?.nameRow.value = "Test Name"
                        newAccountVC?.typeRow.value = type
                        newAccountVC?.balanceRow.value = 120.00
                        newAccountVC?.dateRow.value = date
                        newAccountVC?.colorsRow.value = UIColor.black
                        
                        _ = newAccountVC?.perform(newAccountVC?.navigationItem.rightBarButtonItem?.action)
                    }
                    
                    it("returns all values to delegate", closure: {
                        expect(mockAccountsVC).toNot(beNil())
                        expect(mockAccountsVC?.didCreate) == true
                        expect(mockAccountsVC?.createdName) == "Test Name"
                        expect(mockAccountsVC?.createdType) == type
                        expect(mockAccountsVC?.createdBalance) == 120.0
                        expect(mockAccountsVC?.createdDate) == date
                        expect(mockAccountsVC?.createdColor) == UIColor.black
                    })
                })
            })
        }
    }
}
