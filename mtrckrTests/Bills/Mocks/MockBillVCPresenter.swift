//
//  MockBillVCPresenter.swift
//  mtrckrTests
//
//  Created by User on 8/21/17.
//

import UIKit
@testable import mtrckr

class MockBillVCPresenter: BillVCPresenter {
    var didPresent = false
    var didReceiveId: String?
    
    var didShowHistory = false
    var didShowHistoryOf: Bill?
    
    override func presentNewBill(presenter: UIViewController & NewBillViewControllerDelegate,
                                 billEntry: BillEntry?) {
        didPresent = true
        didReceiveId = billEntry?.id
    }
    
    override func presentPayment(ofBill entry: BillEntry,
                                 presenter: UIViewController & PayBillViewControllerDelegate) {
        didPresent = true
        didReceiveId = entry.id
    }
    
    override func presentHistory(ofBill bill: Bill, presenter: UIViewController) {
        didShowHistory = true
        didShowHistoryOf = bill
    }
    
}
