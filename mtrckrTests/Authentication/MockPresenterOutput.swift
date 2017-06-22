//
//  MockLoginViewController.swift
//  mtrckr
//
//  Created by User on 6/22/17.
//
//

import UIKit
@testable import mtrckr

class MockPresenterOutput: RealmAuthPresenterOutput {
    
    var didFailAuth: Bool = false
    var didSuccessfulLogin: Bool = false
    var didSuccessfulRegistration: Bool = false
    var didSuccessfulLogout: Bool = false
    
    func showFailedAuth(withAlert alert: UIAlertController?) {
        didFailAuth = true
    }
    
    func showSuccessfulLogin(ofUser user: MTSyncUser) {
        didSuccessfulLogin = true
    }
    
    func showSuccessfulRegistration(ofUser user: MTSyncUser) {
        didSuccessfulRegistration = true
    }
    
    func showSuccesfulLogout() {
        didSuccessfulLogout = true
    }
    
}
