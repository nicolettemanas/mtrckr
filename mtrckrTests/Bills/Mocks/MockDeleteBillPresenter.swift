//
//  MockDeleteBillPresenter.swift
//  mtrckrTests
//
//  Created by User on 8/22/17.
//

import UIKit
@testable import mtrckr

class MockDeleteBillPresenter: DeleteBillPresenter {
    var didPresentDeleteSheet = false
    var billEntryToDelete: BillEntry?
    
    override init() {
        super.init()
        self.action = MockAlertAction.self
    }    
    
    override func presentDeleteSheet(presentingVC: DeleteBillPresenterDelegate, forBillEntry entry: BillEntry) {
        super.presentDeleteSheet(presentingVC: presentingVC, forBillEntry: entry)
        didPresentDeleteSheet = true
        billEntryToDelete = entry
    }
}
