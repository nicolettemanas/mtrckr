//
//  RealmAuthPresenterTests.swift
//  mtrckr
//
//  Created by User on 6/15/17.
//
//

import UIKit
import Nimble
import Quick
@testable import mtrckr

class RealmAuthPresenterTests: QuickSpec {

    var authPresenter: RealmAuthPresenterProtocol?
    
    override func spec() {
        describe("RealmAuthPresenter") {
            var mockEncrypter: MockEncrypter?
            var mockRegInteractor: MockRegInteractor?
            var mockLoginInteractor: MockLoginInteractor?
            
            beforeEach {
                mockEncrypter = MockEncrypter()
                mockRegInteractor = MockRegInteractor(withConfig: RealmAuthConfig())
                mockLoginInteractor = MockLoginInteractor()
                self.authPresenter = RealmAuthPresenter(regInteractor: mockRegInteractor,
                                                        loginInteractor: mockLoginInteractor,
                                                        logoutInteractor: nil,
                                                        encrypter: mockEncrypter,
                                                        output: nil)
            }
            
            describe("Logging in", {
                it("Encrypts passwords then calls interactor's log in", closure: {
                    self.authPresenter?.login(withEmail: "email", withPassword: "pw", loginSyncOption: .append)
                    expect(mockEncrypter?.didEncrypt) == true
                    expect(mockLoginInteractor?.didLogin) == true
                })
            })
            
            describe("Signing up", {
                it("Encrypts passwords then calls interactor's sign up", closure: {
                    self.authPresenter?.register(withEmail: "email", withPassword: "pw", withName: "name")
                    expect(mockEncrypter?.didEncrypt) == true
                    expect(mockRegInteractor?.didRegister) == true
                })
            })
        }
    }
}
