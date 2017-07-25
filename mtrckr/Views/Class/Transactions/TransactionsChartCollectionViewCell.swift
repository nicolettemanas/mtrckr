//
//  TransactionsChartCollectionViewCell.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit
import Charts
import Realm
import RealmSwift

class TransactionsChartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var toalAmountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setValues(of transactions: Results<Transaction>?, centerText: String) {
        var dataEntries: [PieChartDataEntry] = []
        guard let trnsctns: Results<Transaction> = transactions else {
            return
        }
        
        for trans in trnsctns {
            let a: PieChartDataEntry = PieChartDataEntry(value: trans.amount)
            dataEntries.append(a)
        }
        
        pieChart.chartDescription = nil
        pieChart.holeRadiusPercent = 0.80
        pieChart.legend.enabled = false
        pieChart.backgroundColor = MTColors.lightBg
        pieChart.centerText = centerText
        pieChart.drawEntryLabelsEnabled = false
        pieChart.rotationEnabled = false
        
        let dataSet = PieChartDataSet(values: dataEntries, label: "")
        dataSet.setColors(MTColors.colors, alpha: 1)
        
        let data = PieChartData(dataSet: dataSet)
        
        pieChart.data = data
    }
}
