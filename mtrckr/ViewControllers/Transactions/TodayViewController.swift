//
//  TodayViewController.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit
import RealmSwift

protocol TodayViewControllerProtocol {
    
}

class TodayViewController: MTViewController, TodayViewControllerProtocol, TransactionsTableViewControllerProtocol,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NewTransactionViewControllerDelegate {
    
    var account: Account?
    
    // MARK: - Properties
    var newTransPresenter: NewTransactionPresenterProtocol?
    var transactionsPresenter: TransactionsPresenter?
    var date: Date = Date()
    var transactionsDataSource: TransactionsListDataSource?
    
    // MARK: - Outlets
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    @IBOutlet weak var transactionsTable: UITableView!
    
    @IBAction func calBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func newTransactionBtnPressed(_ sender: Any) {
        newTransPresenter?.presentNewTransactionVC(with: nil, presentingVC: self, delegate: self)
    }
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        chartsCollectionView.register(UINib(nibName: "TransactionsChartCollectionViewCell",
                                            bundle: Bundle.main), forCellWithReuseIdentifier: "TransactionsChartCollectionViewCell")
        transactionsTable.register(UINib(nibName: "TransactionTableViewCell", bundle: Bundle.main),
                                   forCellReuseIdentifier: "TransactionTableViewCell")
        transactionsDataSource = TransactionsListDataSource(authConfig: RealmAuthConfig(),
                                                            parentVC: self,
                                                            tableView: transactionsTable,
                                                            filterBy: .byDate)
        transactionsPresenter = TransactionsPresenter(with: TransactionsInteractor(with: RealmAuthConfig()))
        transactionsTable.dataSource = transactionsDataSource
        transactionsTable.delegate = transactionsDataSource
        transactionsTable.tableFooterView = UIView()
        newTransPresenter = NewTransactionPresenter()
    }
    
    // MARK: - NewTransactionViewControllerDelegate methods
    func shouldSaveTransaction(with name: String, amount: Double, type: TransactionType, date: Date, category: Category?,
                               from sourceAcc: Account, to destAccount: Account) {
        transactionsPresenter?.createTransaction(with: name, amount: amount, type: type, date: date,
                                                 category: category, from: sourceAcc, to: destAccount)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout and UICollectionViewDataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionsChartCollectionViewCell",
                                                      for: indexPath) as? TransactionsChartCollectionViewCell
        let date = transactionsDataSource?.dateFilter
        var centerText = date!.format(with: "MMM dd")
        centerText = "\(centerText)\n\(date!.day)"
        cell?.setValues(of: transactionsDataSource?.transactions, centerText: centerText)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 260)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
