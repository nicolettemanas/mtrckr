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
            var account3: Account!
            
            var trans1: Transaction!
            var trans2: Transaction!
            var trans3: Transaction!
            var trans4: Transaction!
            var trans5: Transaction!
            var trans6: Transaction!
            
            var date1: Date!
            var date2: Date!
            var date3: Date!
            
            beforeEach {
                
                let accountType1 = fakeModels.accountType(id: 100)
                let accountType2 = fakeModels.accountType(id: 101)
                
                date1 = Date(dateString: "09-11-2017 1:00PM", format: "MM-dd-yyyy hh:mmaa")
                date2 = date1.add(2.days)
                date3 = date1.add(2.hours)
                
                accountType1.save(toRealm: dataSource!.realmContainer!.userRealm!)
                accountType2.save(toRealm: dataSource!.realmContainer!.userRealm!)
                
                account1 = fakeModels.account()
                account2 = fakeModels.account()
                account3 = fakeModels.account()
                
                account1.type = accountType1
                account2.type = accountType2
                account3.type = accountType1
                
                account1.save(toRealm: realm)
                account2.save(toRealm: realm)
                account3.save(toRealm: realm)
                
                trans1 = fakeModels.transaction()
                trans2 = fakeModels.transaction()
                trans3 = fakeModels.transaction()
                trans4 = fakeModels.transaction()
                trans5 = fakeModels.transaction()
                trans6 = fakeModels.transaction()
                
                trans1.fromAccount = account1
                trans1.toAccount = account1
                trans1.transactionDate = date1
                trans2.fromAccount = account1
                trans2.toAccount = account1
                trans2.transactionDate = date2
                trans3.fromAccount = account2
                trans3.toAccount = account2
                trans3.transactionDate = date3
                trans4.fromAccount = account3
                trans4.toAccount = account3
                trans4.transactionDate = date3.add(1.hours)
                trans5.fromAccount = account1
                trans5.toAccount = account1
                trans5.transactionDate = date1.subtract(1.months).add(1.minutes)
                trans6.fromAccount = account1
                trans6.toAccount = account1
                trans6.transactionDate = date1.subtract(1.months)
                
                trans1.save(toRealm: realm)
                trans2.save(toRealm: realm)
                trans3.save(toRealm: realm)
                trans4.save(toRealm: realm)
                trans5.save(toRealm: realm)
                trans6.save(toRealm: realm)
            }
            
            context("filtered by account", {
                beforeEach {
                    dataSource?.accountsFilter = [account1]
                    dataSource?.filterBy = .byAccount
                    dataSource?.reloadByAccounts(with: [account1])
                }
                
                it("displays transactions (sorted latest first) that belongs to the given account", closure: {
                    let numOfRows = dataSource?.tableView(mockTableViewController!.tableView,
                                                               numberOfRowsInSection: 0)
                    expect(numOfRows) == 2
                    
                    let rows = dataSource?.groupedTransactions[trans1.transactionDate.format(with: "MMM")]
                    
                    expect(trans2) == rows!![0]
                    expect(trans1) == rows!![1]
                })
                
                it("sections table by month", closure: {
                    let numOfSections = dataSource?.numberOfSections(in: mockTableViewController!.tableView)
                    let numOfRows = dataSource?.tableView(mockTableViewController!.tableView,
                                                          numberOfRowsInSection: 1)
                    expect(numOfSections) == 2
                    expect(numOfRows) == 2
                    
                    let rows = dataSource?.groupedTransactions[trans5.transactionDate.format(with: "MMM")]
                    
                    expect(trans5) == rows!![0]
                    expect(trans6) == rows!![1]
                })
            })
            
            context("when filtered by date", {
                it("displays transactions (sorted latest first) that was recorded at the given date", closure: {
                    dataSource?.dateFilter = date1
                    dataSource?.filterBy = .byDate
                    dataSource?.reloadByDate(with: date1)
                    let numOfRows = dataSource?.tableView(mockTableViewController!.tableView,
                                                          numberOfRowsInSection: 0)
                    expect(numOfRows).toEventually(equal(3))
                    let t1 = dataSource?.transactions?[0]
                    let t2 = dataSource?.transactions?[1]
                    let t3 = dataSource?.transactions?[2]
                    
                    expect(t1) == trans4
                    expect(t2) == trans3
                    expect(t3) == trans1
                })
            })
            
            context("when filtered by date and account", {
                it("displays transactions (sorted latest first) that was recorded at the given date and belongs to the given accounts", closure: {
                    dataSource?.dateFilter = date1
                    dataSource?.accountsFilter = [account1, account3]
                    dataSource?.filterBy = .both
                    dataSource?.reloadBy(accounts: [account1, account3], date: date1)
                    let numOfRows = dataSource?.tableView(mockTableViewController!.tableView,
                                                          numberOfRowsInSection: 0)
                    expect(numOfRows).toEventually(equal(2))
                    let t1 = dataSource?.transactions?.first
                    let t2 = dataSource?.transactions?.last
                    
                    expect(t1) == trans4
                    expect(t2) == trans1
                })
            })
        }
    }
}
