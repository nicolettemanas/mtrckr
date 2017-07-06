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
    @IBOutlet weak var balanceRemaining: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.layer.masksToBounds = true
        iconView.layer.cornerRadius = 10
        iconView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setValues(ofTransaction transaction: Transaction, withCurrency curr: String) {
        let limit = MTColors.colors.count
            
        // TODO: Set colors per category, remove randomization
        self.iconView.backgroundColor = MTColors.colors[Int(arc4random_uniform(UInt32(limit)) + 1)]
        self.icon.image = UIImage(named: transaction.category!.icon)
        self.itemName.text = transaction.name
        
        // TODO: Get account to know the symbol when type is transfer
        var prefix = ""
        if transaction.type == TransactionType.expense.rawValue { prefix = "-" }
        else if transaction.type == TransactionType.income.rawValue { prefix = "+" }
        
        self.itemPrice.text = prefix + NumberFormatter.currencyStr(withCurrency: curr,
                                                                   amount: transaction.amount)!
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "MMM dd, yyyy"
        self.dateOfTransaction.text = dFormatter.string(from: transaction.transactionDate)
        
        // TODO: Add balance remaining in transactions
        self.balanceRemaining.text = prefix + NumberFormatter.currencyStr(withCurrency: curr,
                                                                          amount: transaction.fromAccount!.currentAmount)!
    }

}
