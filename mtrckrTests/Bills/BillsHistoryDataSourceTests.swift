//
//  BillsHistoryDataSourceTests.swift
//  mtrckrTests
//
//  Created by User on 10/30/17.
//

import UIKit
import Quick
import Nimble
import RealmSwift
import DateToolsSwift
@testable import mtrckr

class BillsHistoryDataSourceTests: QuickSpec {

    override func spec() {
        let identifier = "BillsHistoryDataSourceTests"
        
        let fakeModels = FakeModels()
        let stubResolver = StubMTResolvers()
        
        var mockHistoryVC: BillHistoryViewController!
        var dataSource: BillHistoryDataSourceProtocol!
        var mockInteractor: BillsInteractorProtocol!
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
        
        describe("BillsHistoryDataSource") {
            beforeEach {
                mockInteractor = stubResolver.container.resolve(BillsInteractor.self,
                                                                name: "stub",
                                                                argument: identifier)
                bill!.startDate = Date().subtract(2.months)
                mockInteractor.saveBill(bill: bill!)
                
                mockHistoryVC = stubResolver.container
                    .resolve(BillHistoryViewController.self,
                             name       : "testable",
                             arguments  : bill!, identifier)
                dataSource = mockHistoryVC.dataSource
                
                expect(mockHistoryVC.view).toNot(beNil())
            }
            
            context("given a bill to display history", {
                var date1: Date!
                var entry1: BillEntry!
                var entry2: BillEntry!
                
                beforeEach {
                    // pay two entries
                    let entries = BillEntry.all(in: realm, for: bill!)
                    date1 = Date()
                    
                    entry1 = entries[0]
                    entry1.pay(amount       : 200,
                               description  : "",
                               fromAccount  : fakeModels.account(),
                               datePaid     : date1,
                               inRealm      : realm)
                    
                    entry2 = entries[1]
                    entry2.skip(inRealm: realm)
                    dataSource.refreshHistory()
                }
                
                it("displays first section as header", closure: {
                    let sections = dataSource.numberOfSections!(in: mockHistoryVC.tableView)
                    expect(sections) == 2
                })
                
                it("displays paid and skipped entries sorted by due date in the next section", closure: {
                    let rows = dataSource?.tableView(mockHistoryVC.tableView, numberOfRowsInSection: 1)
                    expect(rows) == 2
                    
                    expect(dataSource?.history).toNot(beNil())
                    let hist1 = dataSource?.history![0]
                    let hist2 = dataSource?.history![1]
                    expect(hist1) == entry2
                    expect(hist2) == entry1
                })
            })
        }
    }
    
}
