//
//  TransactionTableViewCell.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit
import SwipeCellKit

class TransactionTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var dateOfTransaction: UILabel!
    @IBOutlet weak var accountUsed: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.layer.masksToBounds = true
        iconView.layer.cornerRadius = 10
        iconView.clipsToBounds = true
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(ofTransaction transaction: Transaction, withCurrency curr: String) {
        self.itemName.text = transaction.name
        
        var prefix: String = ""
        var color: String? = transaction.category?.color
        var imgIcon: String? = transaction.category?.icon
        var accountUsed: String? = transaction.fromAccount?.name
        if transaction.type == TransactionType.expense.rawValue {
            prefix = "-"
            self.itemPrice.textColor = MTColors.mainRed
        } else if transaction.type == TransactionType.income.rawValue {
            prefix = "+"
            self.itemPrice.textColor = MTColors.mainGreen
        } else {
            self.itemPrice.textColor = MTColors.subText
            color = "#6A7FDBFF"
            imgIcon = "sync"
            accountUsed = "\(transaction.fromAccount!.name) > \(transaction.toAccount!.name)"
        }
        
        self.iconView.backgroundColor = UIColor(color!)
        self.icon.image = UIImage(named: imgIcon!)
        self.accountUsed.text = accountUsed
        self.itemPrice.text = prefix + NumberFormatter.currencyStr(withCurrency: curr,
                                                                   amount: transaction.amount)!
        let dFormatter: DateFormatter = DateFormatter()
        dFormatter.dateFormat = "MMM dd, yyyy"
        self.dateOfTransaction.text = dFormatter.string(from: transaction.transactionDate)
        
    }

}
