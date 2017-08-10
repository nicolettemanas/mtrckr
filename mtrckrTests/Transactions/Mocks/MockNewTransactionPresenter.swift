//
//  MockNewTransactionPresenter.swift
//  mtrckrTests
//
//  Created by User on 8/6/17.
//

import UIKit
@testable import mtrckr

class MockNewTransactionPresenter: NewTransactionPresenter {
    var didPresent = false
    var didPresentTransaction: Transaction?
    override func presentNewTransactionVC(with transaction: Transaction?,
                                          presentingVC: UIViewController,
                                          delegate: NewTransactionViewControllerDelegate) {
        didPresent = true
        didPresentTransaction = transaction
    }
}

class MockDeleteTransactionSheetPresenter: DeleteTransactionSheetPresenter {
    var didPresentDeletSheet = false
    var transactionToDelete: Transaction?
    override func displayDeleteSheet(toDelete transaction: Transaction,
                                     presentingVC: DeleteTransactionSheetPresenterDelegate) {
        didPresentDeletSheet = true
        transactionToDelete = transaction
    }
}
