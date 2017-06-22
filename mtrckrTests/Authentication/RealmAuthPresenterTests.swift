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

    var authPresenter: RealmAuthPresenter?
    
    override func spec() {
        describe("RealmAuthPresenter") {
            var mockEncrypter: MockEncrypter?
            var mockRegInteractor: MockRegInteractor?
            var mockLoginInteractor: MockLoginInteractor?
            var output: MockPresenterOutput?
            
            beforeEach {
                mockEncrypter = MockEncrypter()
                mockRegInteractor = MockRegInteractor(withConfig: RealmAuthConfig())
                mockLoginInteractor = MockLoginInteractor()
                self.authPresenter = RealmAuthPresenter(regInteractor: mockRegInteractor,
                                                        loginInteractor: mockLoginInteractor,
                                                        logoutInteractor: nil,
                                                        encrypter: mockEncrypter,
                                                        output: nil)
                mockLoginInteractor?.output = self.authPresenter
            }
            
            describe("Logging in", {
                beforeEach {
                    output = MockPresenterOutput()
                    self.authPresenter?.output = output
                }
                
                it("Encrypts passwords then calls interactor's log in", closure: {
                    self.authPresenter?.login(withEmail: "email", withPassword: "pw", loginSyncOption: .append)
                    expect(mockEncrypter?.didEncrypt) == true
                    expect(mockLoginInteractor?.didLogin) == true
                })
                
                context("Successful login", {
                    it("Informs output of successful login", closure: {
                        self.authPresenter?.login(withEmail: "email", withPassword: "pw", loginSyncOption: .append)
                        expect(output?.didSuccessfulLogin).toEventually(beTrue())
                    })
                })
                
                context("Failed login", { 
                    it("Informs output of failed login", closure: {
                        self.authPresenter?.loginInteractor = StubFailedLoginInteractor()
                        self.authPresenter?.loginInteractor?.output = self.authPresenter
                        self.authPresenter?.login(withEmail: "", withPassword: "", loginSyncOption: .append)
                        expect(output?.didSuccessfulLogin) == false
                        expect(output?.didFailAuth).toEventually(beTrue())
                    })
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
