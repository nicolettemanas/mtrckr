//
//  TodayViewController.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit

protocol TodayViewControllerProtocol {
    
}

class TodayViewController: MTViewController, TodayViewControllerProtocol,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var calendarBtn: UIButton!
    @IBAction func calBtnPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    @IBOutlet weak var transactionsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartsCollectionView.delegate = self
        chartsCollectionView.dataSource = self
        chartsCollectionView.register(UINib(nibName: "TransactionsChartCollectionViewCell",
                                            bundle: Bundle.main), forCellWithReuseIdentifier: "TransactionsChartCollectionViewCell")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionsChartCollectionViewCell",
                                                      for: indexPath) as? TransactionsChartCollectionViewCell
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
