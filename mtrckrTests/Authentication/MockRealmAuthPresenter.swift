//
//  MockRealmAuthPresenter.swift
//  mtrckr
//
//  Created by User on 6/15/17.
//
//

import UIKit
@testable import mtrckr

class MockRealmAuthPresenter: RealmAuthPresenter {
    
    var didLogin: Bool = false
    var didRegister: Bool = false
    var didLogout: Bool = false
    
    init() {
        super.init(regInteractor: nil, loginInteractor: nil, logoutInteractor: nil, encrypter: nil, output: nil)
    }
    
    override func login(withEmail email: String, withPassword password: String, loginSyncOption option: LoginSyncOption) {
        didLogin = true
    }
    
    override func register(withEmail email: String, withPassword password: String, withName name: String) {
        didRegister = true
    }
    
    override func logout() {
        didLogout = true
    }
    
    override func didRegister(user: MTSyncUser) {
        didRegister = true
    }
    
    override func didLogin(user: MTSyncUser) {
        didLogin = true
    }
    
    override func didFailLogin(withError error: Error?) {
        didLogin = false
    }
    
    override func didFailRegistration(withError error: Error?) {
        didRegister = false
    }
    
}
