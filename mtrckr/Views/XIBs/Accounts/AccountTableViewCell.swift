//
//  AccountTableViewCell.swift
//  mtrckr
//
//  Created by User on 6/30/17.
//

import UIKit
import SwipeCellKit

class AccountTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typeView.layer.masksToBounds = true
        typeView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setValues(ofAccount acc: Account, withCurrency currency: String) {
        nameLabel.text = acc.name
        
        typeView.backgroundColor = .white
        typeView.layer.borderColor = UIColor(acc.color).cgColor
        typeView.layer.borderWidth = 1
        
        typeImageView.tintColor = UIColor(acc.color)
        typeImageView.image = UIImage(named: acc.type!.icon)
        
        typeLabel.text = acc.type!.name
        typeLabel.textColor = UIColor(acc.color)
        
        amountLabel.text = NumberFormatter.currencyStr(withCurrency: currency,
                                                       amount: acc.currentAmount)
    }

}
