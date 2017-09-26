//
//  MockNewBillPresenter.swift
//  mtrckrTests
//
//  Created by User on 8/21/17.
//

import UIKit
@testable import mtrckr

class MockNewBillPresenter: NewBillPresenter {
    var didPresent = false
    var didReceiveId: String?
    
    var editBillIndexPath: IndexPath?
    
    override func presentNewBill(presenter: NewBillViewControllerDelegate, billEntry: BillEntry?) {
        didPresent = true
        didReceiveId = billEntry?.id
    }
}
