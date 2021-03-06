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
            self.itemPrice.textColor = Colors.mainRed.color
        } else if transaction.type == TransactionType.income.rawValue {
            prefix = "+"
            self.itemPrice.textColor = Colors.mainGreen.color
        } else {
            self.itemPrice.textColor = Colors.subText.color
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
        if transaction.transactionDate.year == Date().year {
            dFormatter.dateFormat = "MMM dd"
        }
        self.dateOfTransaction.text = dFormatter.string(from: transaction.transactionDate)
    }
}
