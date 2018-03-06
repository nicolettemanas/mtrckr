//
//  BillsDataSourceTests.swift
//  mtrckrTests
//
//  Created by User on 8/15/17.
//

import UIKit
import Nimble
import Quick
import RealmSwift
@testable import mtrckr

class BillsDataSourceTests: QuickSpec {
    override func spec() {
        let identifier = "BillsDataSourceTests"

        var dataSource: BillsDataSource!
        var interactor: BillsInteractor!
        var fakeModels: FakeModels!
        var realm: Realm!
        var mockBillsTableViewController: BillsTableViewController!
        var realmHolder: StubRealm!

        beforeEach {
            realmHolder = StubRealm(identifier: identifier)
            realm = realmHolder.realmContainer!.userRealm!
            try! realm.write {
                realm.deleteAll()
            }

            dataSource = BillsDataSource(with: RealmAuthConfig())
            dataSource?.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
            dataSource?.realmContainer?.setDefaultRealm(to: .offline)

            mockBillsTableViewController = StubMTResolvers.shared.container.resolve(BillsTableViewController.self, name: "stub",
                                                                      argument: dataSource as BillsDataSourceProtocol)
            dataSource.delegate = mockBillsTableViewController
            interactor = BillsInteractor(with: RealmAuthConfig())
            interactor.realmContainer = MockRealmContainer(memoryIdentifier: identifier)
            interactor.realmContainer?.setDefaultRealm(to: .offline)

            fakeModels = FakeModels()
            realm = dataSource.realmContainer!.userRealm!
        }

        describe("BillsDataSource") {
            var bill1: Bill!
            var bill2: Bill!
            var bill3: Bill!
            var bill4: Bill!

            beforeEach {
                bill1 = fakeModels.bill()
                bill2 = fakeModels.bill()
                bill3 = fakeModels.bill()
                bill4 = fakeModels.bill()

                bill2.startDate = Date().subtract(2.months)
                bill3.startDate = Date().add(5.days)
                bill4.startDate = Date().add(1.months)

                interactor.saveBill(bill: bill1)
                interactor.saveBill(bill: bill2)
                interactor.saveBill(bill: bill3)
                interactor.saveBill(bill: bill4)
                
                expect(mockBillsTableViewController?.view).toNot(beNil())
            }

            it("displays all unpaid bill entry counterparts sorted to latest due date first", closure: {
                let numOfSections = dataSource.numberOfSections(in: mockBillsTableViewController!.tableView)
                expect(numOfSections) == 3

                expect(dataSource.billEntries!.count) == 6
                expect(dataSource.billEntries![0].dueDate) <= dataSource.billEntries![1].dueDate
                expect(dataSource.billEntries![1].dueDate) <= dataSource.billEntries![2].dueDate
            })

            it("grouped according to due date: overdue, next 7 days, next month", closure: {
                let numOfRows0 = dataSource.tableView(mockBillsTableViewController!.tableView,
                                                      numberOfRowsInSection: 0)
                let numOfRows1 = dataSource.tableView(mockBillsTableViewController!.tableView,
                                                      numberOfRowsInSection: 1)
                let numOfRows2 = dataSource.tableView(mockBillsTableViewController!.tableView,
                                                      numberOfRowsInSection: 2)

                expect(numOfRows0) == 4
                expect(numOfRows1) == 1
                expect(numOfRows2) == 1
            })

            it("uses BillCell", closure: {
                let cell = dataSource.tableView(mockBillsTableViewController.tableView,
                                     cellForRowAt: IndexPath(item: 0, section: 0))
                expect(cell.isKind(of: BillsCell.self)).to(beTrue())
            })
        }
    }
}
