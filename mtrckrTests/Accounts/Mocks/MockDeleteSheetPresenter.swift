//
//  MockDeleteSheetPresenter.swift
//  mtrckrTests
//
//  Created by User on 7/4/17.
//

import UIKit
@testable import mtrckr

class MockDeleteSheetPresenter: DeleteSheetPresenter {
    var didPresentDeleteSheet = false
    var indexToDelete: IndexPath?
    
    override func displayDeleteSheet(toDelete indexPath: IndexPath, presentingVC: AccountsTableViewController) {
        didPresentDeleteSheet = true
        indexToDelete = indexPath
    }
}
