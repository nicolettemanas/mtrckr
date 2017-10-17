//
//  TransactionTableViewControllerTests.swift
//  mtrckrTests
//
//  Created by User on 8/6/17.
//

import UIKit
import Quick
import Nimble
import RealmSwift
import SwipeCellKit
@testable import mtrckr

class TransactionTableViewControllerTests: QuickSpec {
    var storyboard: UIStoryboard?
    var transactionsTVC: TransactionsTableViewController?
    
    var mockPresenter: MockTransactionsPresenter?
    var mockInteractor: MockTransactionsInteractor?
    
    var mockNewTransPresenter: MockNewTransactionPresenter?
    var mockDeleteTransactionSheetPresenter: MockDeleteTransactionSheetPresenter?
    
    var identifier = "AccountsTableViewControllerTests"
    
    override func spec() {
        
        beforeEach {
            self.storyboard = UIStoryboard(name: "Today", bundle: Bundle.main)
        }
        
        describe("TransactionTableViewControllerTests") {
            
            var realm: Realm?
            
            beforeEach {
                var config = Realm.Configuration()
                config.inMemoryIdentifier = self.identifier
                realm = try? Realm(configuration: config)
                try! realm?.write {
                    realm!.deleteAll()
                }
                
                self.mockInteractor = MockTransactionsInteractor(with: RealmAuthConfig())
                self.mockPresenter = MockTransactionsPresenter(with: self.mockInteractor!)
                self.mockNewTransPresenter = MockNewTransactionPresenter()
                self.mockDeleteTransactionSheetPresenter = MockDeleteTransactionSheetPresenter()
                
                self.transactionsTVC = StubMTResolvers().container.resolve(TransactionsTableViewController.self, name: "stub",
                                                                                       argument: TransactionsFilter.byDate)
                expect(self.transactionsTVC?.view).toNot(beNil())
                self.transactionsTVC?.transactionsPresenter = self.mockPresenter
                self.transactionsTVC?.deleteTransactionSheetPresenter = self.mockDeleteTransactionSheetPresenter
                self.transactionsTVC?.newTransPresenter = self.mockNewTransPresenter
                
            }
            
            context("swipe left a cell to display actions", {
                it("displays two options: Edit and Delete", closure: {
                    let actions = self.transactionsTVC?.tableView(self.transactionsTVC!.tableView,
                                                                  editActionsForRowAt: IndexPath(item: 0, section: 0),
                                                                  for: SwipeActionsOrientation.right)
                    expect(actions?.first?.accessibilityLabel) == "Delete"
                    expect(actions?.last?.accessibilityLabel) == "Edit"
                })
                
                context("taps edit transaction", {
                    it("presents a viewcontroller to edit transaction", closure: {
                        let actions = self.transactionsTVC?.tableView(self.transactionsTVC!.tableView,
                                                                      editActionsForRowAt: IndexPath(item: 0, section: 0),
                                                                      for: SwipeActionsOrientation.right)
                        let edit = actions?.last
                        edit?.handler?(edit!, IndexPath(item: 0, section: 0))
                        expect(self.mockNewTransPresenter?.didPresent) == true
                    })
                })
                
                context("taps delete transaction", {
                    it("tells the presenter to display sheet confirming whether to delete transaction", closure: {
                        let actions = self.transactionsTVC?.tableView(self.transactionsTVC!.tableView,
                                                                      editActionsForRowAt: IndexPath(item: 0, section: 0),
                                                                      for: SwipeActionsOrientation.right)
                        let delete = actions?.first
                        delete?.handler?(delete!, IndexPath(item: 0, section: 0))
                        expect(self.mockDeleteTransactionSheetPresenter?.didPresentDeletSheet) == true
                    })
                })
            })
        }
    }
}
