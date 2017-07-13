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
        setValues(of: nil)
    }
    
    func setValues(of transactions: Results<Transaction>?) {
        var dataEntries: [PieChartDataEntry] = []
//        for trans in transactions {
//            let a = PieChartDataEntry(value: trans.amount)
//            dataEntries.append(a)
//        }
        
        pieChart.chartDescription = nil
        pieChart.holeRadiusPercent = 0.80
        pieChart.legend.enabled = false
        pieChart.backgroundColor = MTColors.lightBg
        pieChart.centerText = "April 25\nTUESDAY"
        pieChart.drawEntryLabelsEnabled = false
        pieChart.rotationEnabled = false
        
        for i in 1..<5 {
            let a = PieChartDataEntry(value: Double(i))
            dataEntries.append(a)
        }
        
        let dataSet = PieChartDataSet(values: dataEntries, label: "")
        dataSet.setColors(MTColors.colors, alpha: 1)
        
        let data = PieChartData(dataSet: dataSet)
        
        pieChart.data = data
    }
}
