//
//  LoginViewControllerTests.swift
//  mtrckr
//
//  Created by User on 6/22/17.
//
//

import UIKit
import Quick
import Nimble
@testable import mtrckr

class LoginViewControllerTests: QuickSpec {
    var storyboard: UIStoryboard?
    var loginVC: LoginViewController?
    var mockPresenter: MockRealmAuthPresenter?
    
    override func spec() {
        beforeSuite {
            self.storyboard = UIStoryboard(name: "Settings", bundle: Bundle.main)
        }
        
        describe("RegistrationViewController") {
            beforeEach {
                self.loginVC = self.storyboard?
                    .instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
                self.mockPresenter = MockRealmAuthPresenter()
                
                self.loginVC?.presenter = self.mockPresenter
                self.loginVC?.beginAppearanceTransition(true, animated: false)
                self.loginVC?.endAppearanceTransition()
            }
            
            context("No provided credentials", {
                it("Login will not proceed", closure: {
                    self.loginVC?.emailTxtField.text = ""
                    self.loginVC?.passwordTxtField.text = ""
                    self.loginVC?.loginBtnPressed(nil)
                    self.loginVC?.loginWithOption(option: .append)
                    expect(self.mockPresenter?.didLogin) == false
                })
            })
            
            context("Provided valid credentials", {
                it("Login proceeds", closure: {
                    self.loginVC?.emailTxtField.text = "sample@gmail.com"
                    self.loginVC?.passwordTxtField.text = "sample"
                    self.loginVC?.loginBtnPressed(nil)
                    self.loginVC?.loginWithOption(option: .append)
                    expect(self.mockPresenter?.didLogin) == true
                })
            })
        }
    }
}
