//
//  MockAccountsTableViewController.swift
//  mtrckrTests
//
//  Created by User on 11/13/17.
//

import UIKit
@testable import mtrckr

class MockAccountsTableViewController: NewAccountViewControllerDelegate {

    var didCreate = false
    var createdId: String?
    var createdName: String?
    var createdType: AccountType?
    var createdBalance: Double?
    var createdDate: Date?
    var createdColor: UIColor?
    
    func shouldCreateAccount(withId id: String?, name: String, type: AccountType,
                             initBalance: Double, dateOpened: Date, color: UIColor) {
        didCreate = true
        createdId = id
        createdName = name
        createdType = type
        createdBalance = initBalance
        createdDate = dateOpened
        createdColor = color
    }

}
