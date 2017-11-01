//
//  BillHistoryViewControllerTests.swift
//  mtrckrTests
//
//  Created by User on 10/30/17.
//

import UIKit
import Nimble
import Quick
import RealmSwift
@testable import mtrckr

class BillHistoryViewControllerTests: QuickSpec {
    override func spec() {
        let identifier = "BillHistoryViewControllerTests"
        
        let fakeModels = FakeModels()
        let stubResolver = StubMTResolvers()
        
        var historyViewController: BillHistoryViewController!
        var dataSource: BillHistoryDataSourceProtocol!
        var mockInteractor: BillsInteractorProtocol!
        var mockPresenter: MockBillsPresenter!
        var realm: Realm!
        var bill: Bill?
        
        beforeEach {
            var config = Realm.Configuration()
            config.inMemoryIdentifier = identifier
            realm = try? Realm(configuration: config)
            try! realm.write {
                realm.deleteAll()
            }
            
            bill = fakeModels.bill()
        }
        
        describe("BillHistoryViewControllerTests") {
            beforeEach {
                mockInteractor = stubResolver.container.resolve(BillsInteractor.self,
                                                                name: "stub",
                                                                argument: identifier)
                bill!.startDate = Date().subtract(2.months)
                mockInteractor.saveBill(bill: bill!)
                historyViewController = stubResolver
                    .container.resolve(BillHistoryViewController.self,
                                       name: "testable",
                                       arguments: bill!, identifier)
                
                dataSource = historyViewController.dataSource
                mockPresenter = historyViewController.presenter as! MockBillsPresenter

                expect(dataSource.cellDelegate).toNot(beNil())
            }
            
            context("no bills paid", {
                beforeEach {
                    dataSource?.refreshHistory()
                }
                
                it("displayes footer", closure: {
                    expect(historyViewController.tableView.tableFooterView).toNot(beNil())
                })
            })
            
            context("some bills are paid", {
                beforeEach {
                    let atype = fakeModels.accountType(id: 123)
                    let account = fakeModels.account()
                    account.type = atype
                    account.save(toRealm: realm)
                    
                    mockInteractor.payEntry(entry: (bill?.entries[0])!, amount: 100, account: account, date: Date())
                    mockInteractor.skip(entry: (bill?.entries[1])!, date: Date())
                    
                    dataSource?.refreshHistory()
                }
                
                it("hides footer view", closure: {
                    expect(historyViewController.tableView.tableFooterView).toEventually(beNil())
                })
                
                it("displays paid/skipped items", closure: {
                    dataSource.refreshHistory()
                    let num = dataSource.tableView(historyViewController.tableView, numberOfRowsInSection: 1)
                    expect(num) == 2
                })
                
                context("unpay entries", {
                    var entry1: BillEntry!
                    
                    beforeEach {
                        entry1 = dataSource.history![0]
                        historyViewController.unpay(indexPath: IndexPath(row: 0, section: 0))
                    }
                    
                    it("tells presenter to unpay entry", closure: {
                        expect(mockPresenter.didUnpayEntry) == entry1
                    })
                })
            })
        }
    }
}
