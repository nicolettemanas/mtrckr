//
//  RegistrationTests.swift
//  mtrckr
//
//  Created by User on 6/15/17.
//
//

import UIKit
import Quick
import Nimble
@testable import mtrckr

class RegistrationViewControllerTests: QuickSpec {

    var storyboard: UIStoryboard?
    var regVC: RegistrationViewController?
    var mockPresenter: MockRealmAuthPresenter?
    
    override func spec() {
        beforeSuite {
            self.storyboard = UIStoryboard(name: "Settings", bundle: Bundle.main)
        }
        
        describe("RegistrationViewController") {
            beforeEach {
                self.regVC = self.storyboard?
                    .instantiateViewController(withIdentifier: "RegistrationViewController")
                    as? RegistrationViewController
                self.mockPresenter = MockRealmAuthPresenter()
                
                self.regVC?.presenter = self.mockPresenter
                self.regVC?.beginAppearanceTransition(true, animated: false)
                self.regVC?.endAppearanceTransition()
            }
            
            context("Provided email is in invalid format", {
                it("Registration will not proceed", closure: {
                    self.regVC?.regEmail.text = "sample"
                    self.regVC?.regPw.text = "samplepassword"
                    self.regVC?.regConfirmPw.text = "samplepassword"
                    self.regVC?.createAccountBtnPressed(nil)
                    expect(self.mockPresenter?.didRegister) == false
                })
            })
            
            context("Provided passwords do not match", { 
                it("Registration will not proceed", closure: {
                    self.regVC?.regEmail.text = "sample@gmail.com"
                    self.regVC?.regPw.text = "password1"
                    self.regVC?.regConfirmPw.text = "password2"
                    self.regVC?.createAccountBtnPressed(nil)
                    expect(self.mockPresenter?.didRegister) == false
                })
            })
            
            context("Provided passwords do not exceed five characters", {
                it("Registration will not proceed", closure: {
                    self.regVC?.regEmail.text = "sample@gmail.com"
                    self.regVC?.regPw.text = "p1"
                    self.regVC?.regConfirmPw.text = "p2"
                    self.regVC?.createAccountBtnPressed(nil)
                    expect(self.mockPresenter?.didRegister) == false
                })
            })
            
            context("Provided email is valid format and passwords match", {
                it("Registration proceeds", closure: {
                    self.regVC?.regEmail.text = "email@gmail.com"
                    self.regVC?.regPw.text = "samplepassword"
                    self.regVC?.regConfirmPw.text = "samplepassword"
                    self.regVC?.createAccountBtnPressed(nil)
                    expect(self.mockPresenter?.didRegister) == true
                })
            })
        }
    }
}
