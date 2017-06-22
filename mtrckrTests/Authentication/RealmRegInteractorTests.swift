//
//  RegistrationInteractorTests.swift
//  mtrckr
//
//  Created by User on 6/15/17.
//
//

import UIKit
import Quick
import Nimble
import RealmSwift
@testable import mtrckr

class RealmRegInteractorTests: QuickSpec {
    
    var regInteractor: RealmRegInteractor?
    var regPresenter: MockRealmAuthPresenter?
    var offlineRealm: Realm?
    var syncRealm: Realm?
    
    override func spec() {
        
        beforeEach {
            var config = Realm.Configuration()
            config.inMemoryIdentifier = "RealmRegInteractorTests"
            
            self.offlineRealm = try? Realm(configuration: config)
            try? self.offlineRealm?.write {
                self.offlineRealm?.deleteAll()
            }
            
            config.inMemoryIdentifier = "RealmRegInteractorTests-sync"
            
            self.syncRealm = try? Realm(configuration: config)
            try? self.syncRealm?.write {
                self.syncRealm?.deleteAll()
            }
        }
        
        describe("Registration") {
            context("Successful registration", {
                beforeEach {
                    InitialRealmGenerator.generateInitRealm(onComplete: { (_) in
                        self.regInteractor = TestableRegInteractor("RealmRegInteractorTests")
                        self.regPresenter = MockRealmAuthPresenter()
                        self.regInteractor?.output = self.regPresenter
                        
                        // "Logout"
                        self.regInteractor?.syncUser = nil
                        
                        self.offlineRealm = self.regInteractor?.userRealm
                        let cashAccountType = AccountType.with(key: 218, inRealm: self.offlineRealm!)
                        
                        let account = Account(value: ["id": "accnt1",
                                                      "name": "My Cash",
                                                      "type": cashAccountType!,
                                                      "initialAmount": 10.0,
                                                      "currentAmount": 20.0,
                                                      "totalExpenses": 100.0,
                                                      "totalIncome": 30.0,
                                                      "color": "#AAAAAA",
                                                      "dateOpened": Date() ])
                        account.save(toRealm: self.offlineRealm!)
                        self.regInteractor?.register(withEmail: "sample@gmail.com",
                                                     withEncryptedPassword: "sample",
                                                     withName: "sample")
                    })
                }
                
                it("Saves registered user to synced database", closure: {
                    self.syncRealm = self.regInteractor?.userRealm
                    let syncedUsers = User.all(in: self.syncRealm!)
                    
                    expect(syncedUsers.count).toEventually(equal(1))
                    expect(syncedUsers.first?.email).toEventually(equal("sample@gmail.com"))
                    expect(syncedUsers.first?.name).toEventually(equal("sample"))
                })
                
                it("Syncs offline data to synced realm", closure: {
                    let syncrealm = self.regInteractor?.userRealm
                    let syncedAccounts = Account.all(in: syncrealm!)
                    
                    expect(syncedAccounts.count).toEventually(equal(1))
                    expect(syncedAccounts.first?.id).toEventually(equal("accnt1"))
                    expect(syncrealm?.configuration.inMemoryIdentifier).to(contain("sync"))
                })
                
                it("Calls output's success registration method", closure: { 
                    expect(self.regPresenter?.didRegister).toEventually(equal(true))
                })
            })
            
            context("Failed registration", {
                beforeEach {
                    InitialRealmGenerator.generateInitRealm(onComplete: { (_) in
                        self.regInteractor = StubFailedRegInteractor()
                        self.regPresenter = MockRealmAuthPresenter()
                        self.regInteractor?.output = self.regPresenter
                        
                        // "Logout"
                        self.regInteractor?.syncUser = nil

                        self.regInteractor?.register(withEmail: "sample@gmail.com",
                                                     withEncryptedPassword: "sample",
                                                     withName: "sample")
                    })
                }
                
                it("Informs presenter about error", closure: {
                    expect(self.regPresenter?.didFailRegister).toEventually(beTrue())
                })
            })
        }
        
    }
}
