//
//  MockLoginInteractor.swift
//  mtrckr
//
//  Created by User on 6/15/17.
//
//

import UIKit
@testable import mtrckr

class MockLoginInteractor: RealmLoginInteractor {

    var didLogin = false
    
    init() {
        super.init(with: RealmAuthConfig())
    }
    
    override func login(withEmail email: String, withEncryptedPassword password: String, loginOption option: LoginSyncOption) {
        didLogin = true
        output?.didLogin(user: MTSyncUser())
    }
    
}
