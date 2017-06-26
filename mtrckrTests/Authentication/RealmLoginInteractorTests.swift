//
//  RealmLoginInteractorTests.swift
//  mtrckr
//
//  Created by User on 6/21/17.
//
//

import UIKit
import Quick
import Nimble
import Realm
import RealmSwift
@testable import mtrckr

class RealmLoginInteractorTests: QuickSpec {
    
    var loginInteractor: RealmLoginInteractor?
    var regPresenter: MockRealmAuthPresenter?
    
    var offlineRealm: Realm?
    var syncRealm: Realm?
    
    override func spec() {
        beforeEach {
            var config = Realm.Configuration()
            config.inMemoryIdentifier = "RealmLoginInteractorTests"
            
            self.offlineRealm = try? Realm(configuration: config)
            try? self.offlineRealm?.write {
                self.offlineRealm?.deleteAll()
            }
            
            config.inMemoryIdentifier = "RealmLoginInteractorTests-sync"
            
            self.syncRealm = try? Realm(configuration: config)
            try? self.syncRealm?.write {
                self.syncRealm?.deleteAll()
            }
        }
        
        describe("Login") {
            context("Successful login", {
                beforeEach {
                    InitialRealmGenerator.generateInitRealm(onComplete: { (_) in
                        self.loginInteractor = TestableLoginInteractor("RealmLoginInteractorTests")
                        self.regPresenter = MockRealmAuthPresenter()
                        self.loginInteractor?.output = self.regPresenter
                        
                        // "Logout"
                        self.loginInteractor?.realmContainer?.setDefaultRealm(to: .offline)
                    })
                    self.offlineRealm = self.loginInteractor?.realmContainer?.userRealm
                }
                
                context("User chooses to append data", {
                    beforeEach {
                        let customCat = mtrckr.Category(id: "customCategory1", type: .expense, name: "Expense1", icon: "")
                        customCat.save(toRealm: self.offlineRealm!)
                        
                        self.loginInteractor?.login(withEmail: "sample@gmail.com",
                                                    withEncryptedPassword: "sample",
                                                    loginOption: .append)
                    }
                    
                    itBehavesLike("User is logged in")
                    it("Appends offline data to synced data", closure: {
                        self.syncRealm = self.loginInteractor?.realmContainer?.userRealm
                        let categories = mtrckr.Category.all(in: self.syncRealm!)
                        let customCategory = mtrckr.Category.with(key: "customCategory1", inRealm: self.syncRealm!)
                        
                        expect(categories.count).toEventually(equal(23))
                        expect(customCategory).toNotEventually(beNil())
                    })
                })
                
                context("User chooses to disregard offline data", {
                    beforeEach {
                        let customCat = mtrckr.Category(id: "customCategory1", type: .expense, name: "Expense1", icon: "")
                        customCat.save(toRealm: self.offlineRealm!)
                        
                        self.loginInteractor?.login(withEmail: "sample@gmail.com",
                                                    withEncryptedPassword: "sample",
                                                    loginOption: .useRemote)
                    }
                    
                    itBehavesLike("User is logged in")
                    it("Sync data overwrites offline data", closure: { 
                        self.syncRealm = self.loginInteractor?.realmContainer?.userRealm
                        let categories = mtrckr.Category.all(in: self.syncRealm!)
                        let customCategory = mtrckr.Category.with(key: "customCategory1", inRealm: self.syncRealm!)
                        
                        expect(categories.count).toEventually(equal(0))
                        expect(customCategory).to(beNil())
                    })
                })
            })
            
            context("Failed login", { 
                beforeEach {
                    InitialRealmGenerator.generateInitRealm(onComplete: { (_) in
                        self.loginInteractor = StubFailedLoginInteractor()
                        self.regPresenter = MockRealmAuthPresenter()
                        self.loginInteractor?.output = self.regPresenter
                        
                        // "Logout"
                        self.loginInteractor?.realmContainer?.setDefaultRealm(to: .offline)
                        
                        self.loginInteractor?.login(withEmail: "",
                                                    withEncryptedPassword: "",
                                                    loginOption: .append)
                    })
                }
                
                it("Informs presenter about error", closure: {
                    expect(self.regPresenter?.didFailLogin).toEventually(beTrue())
                })
                
                it("Informs presenter about error", closure: {
                    self.syncRealm = self.loginInteractor?.realmContainer?.userRealm
                    let categories = mtrckr.Category.all(in: self.syncRealm!)
                    let customCategory = mtrckr.Category.with(key: "customCategory1", inRealm: self.syncRealm!)
                    
                    expect(categories.count).toEventually(equal(22))
                    expect(customCategory).to(beNil())
                })
            })
        }
    }
}

class SharedLoginBehaviour: QuickConfiguration {
    
    override class func configure(_ configuration: Configuration) {
        sharedExamples("User is logged in") {
            var syncedRealm: Realm?
            
            beforeEach {
                var syncConfig = Realm.Configuration()
                syncConfig.inMemoryIdentifier = "RealmLoginInteractorTests-sync"
                
                syncedRealm = try? Realm(configuration: syncConfig)
                let currency = Currency(id: "curr1", isoCode: "PHP", symbol: "", state: "")
                let user = User(id: "sample1", name: "sample@gmail.com",
                                email: "sample@gmail.com", image: "",
                                currency: currency)
                
                currency.save(toRealm: syncedRealm!)
                user.save(toRealm: syncedRealm!)
            }
            
            it("Account is synced; Informs presenter upon successful login; uses synced realm", closure: {
                let regPresenter = MockRealmAuthPresenter()
                let loginInteractor = TestableLoginInteractor("RealmLoginInteractorTests")
                loginInteractor.output = regPresenter
                loginInteractor.login(withEmail: "sample@gmail.com",
                                      withEncryptedPassword: "sample",
                                      loginOption: .append)
                
                syncedRealm = loginInteractor.realmContainer?.userRealm
                let syncedUsers = User.all(in: syncedRealm!)
                
                expect(syncedRealm?.configuration.inMemoryIdentifier).toEventually(contain("sync"))
                expect(syncedUsers.count).toEventually(equal(1))
                expect(syncedUsers.first?.name).toEventually(equal("sample@gmail.com"))
                expect(regPresenter.didLogin).toEventually(beTrue())
            })
        }
    }
}
