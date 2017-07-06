//
//  TransactionTableViewCell.swift
//  mtrckr
//
//  Created by User on 7/6/17.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var dateOfTransaction: UILabel!
    @IBOutlet weak var balanceRemaining: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
