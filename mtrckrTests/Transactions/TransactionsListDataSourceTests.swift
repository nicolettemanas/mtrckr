//
//  TransactionsListDataSourceTests.swift
//  mtrckrTests
//
//  Created by User on 8/8/17.
//

import UIKit
import Quick
import Nimble
import RealmSwift
import DateToolsSwift
@testable import mtrckr

class TransactionsListDataSourceTests: QuickSpec {
    override func spec() {
        
        let identifier = "TransactionsListDataSourceTests"
        
        var mockTableViewController: TransactionsTableViewController?
        var dataSource: TransactionsListDataSource?
        var fakeModels: FakeModels!
        var realm: Realm!
        
        beforeEach {
            var config = Realm.Configuration()
            config.inMemoryIdentifier = identifier
            realm = try? Realm(configuration: config)
            try! realm.write {
                realm.deleteAll()
            }
            
            dataSource = TransactionsListDataSource(authConfig: RealmAuthConfig(),
                                                    filterBy: .byAccount,
                                                    date: nil, accounts: [])
            dataSource?.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
            dataSource?.realmContainer?.setDefaultRealm(to: .offline)
            
            let resolver = StubViewControllerResolvers()
            mockTableViewController = resolver.container.resolve(TransactionsTableViewController.self,
                                                                 name: "stub",
                                                                 argument: TransactionsFilter.byAccount)
            dataSource?.delegate = mockTableViewController
            mockTableViewController?.transactionsDataSource = dataSource
            
            fakeModels = FakeModels()
            expect(mockTableViewController?.view).toNot(beNil())
        }
        
        describe("the number of transactions displayed") {
            
            var account1: Account!
            var account2: Account!
            
            var trans1: Transaction!
            var trans2: Transaction!
            var trans3: Transaction!
            
            var date1: Date!
            var date2: Date!
            var date3: Date!
            
            beforeEach {
                
                let accountType1 = fakeModels.accountType(id: 100)
                let accountType2 = fakeModels.accountType(id: 101)
                
                date1 = Date(dateString: "08-10-2017 10:00AM", format: "MM-dd-yyyy hh:mmaa")
                date2 = date1.add(2.days)
                date3 = date1.add(2.hours)
                
                accountType1.save(toRealm: dataSource!.realmContainer!.userRealm!)
                accountType2.save(toRealm: dataSource!.realmContainer!.userRealm!)
                
                account1 = fakeModels.account()
                account2 = fakeModels.account()
                
                account1.type = accountType1
                account2.type = accountType2
                
                account1.save(toRealm: realm)
                account2.save(toRealm: realm)
                
                trans1 = fakeModels.transaction()
                trans2 = fakeModels.transaction()
                trans3 = fakeModels.transaction()
                
                trans1.fromAccount = account1
                trans1.toAccount = account1
                trans1.transactionDate = date1
                trans2.fromAccount = account1
                trans2.toAccount = account1
                trans2.transactionDate = date2
                trans3.fromAccount = account2
                trans3.toAccount = account2
                trans3.transactionDate = date3
                
                trans1.save(toRealm: realm)
                trans2.save(toRealm: realm)
                trans3.save(toRealm: realm)
            }
            
            context("filtered by acount", {
                it("displays transactions (sorted latest first) that belongs to the given account", closure: {
                    dataSource?.accountsFilter = [account1]
                    dataSource?.filterBy = .byAccount
                    dataSource?.reloadByAccounts(with: [account1])
                    let numOfRows = dataSource?.tableView(mockTableViewController!.tableView,
                                                               numberOfRowsInSection: 0)
                    expect(numOfRows).toEventually(equal(2))
                    let t1 = dataSource?.transactions?.first
                    let t2 = dataSource?.transactions?.last
                    
                    expect(trans1) == t2
                    expect(trans2) == t1
                })
            })
            
            context("when filtered by date", {
                it("displays transactions (sorted latest first) that was recorded at the given date", closure: {
                    dataSource?.dateFilter = date1
                    dataSource?.filterBy = .byDate
                    dataSource?.reloadByDate(with: date1)
                    let numOfRows = dataSource?.tableView(mockTableViewController!.tableView,
                                                          numberOfRowsInSection: 0)
                    expect(numOfRows).toEventually(equal(2))
                    let t1 = dataSource?.transactions?.first
                    let t2 = dataSource?.transactions?.last
                    
                    expect(t1) == trans3
                    expect(t2) == trans1
                })
            })
        }
    }
}
