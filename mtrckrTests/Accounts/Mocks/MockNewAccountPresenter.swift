//
//  MockNewAccountPresenter.swift
//  mtrckrTests
//
//  Created by User on 7/4/17.
//

import UIKit
@testable import mtrckr

class MockNewAccountPresenter: NewAccountPresenter {
    var didCallPresent = false
    var didReceiveId = ""
    
    override func presentNewAccountVC(with account: Account?, presentingVC: UIViewController, delegate: NewAccountViewControllerDelegate) {
        didCallPresent = true
        didReceiveId = account?.id ?? ""
    }
}
