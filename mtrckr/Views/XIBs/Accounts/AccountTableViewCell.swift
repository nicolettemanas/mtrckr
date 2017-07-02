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
        typeImageView.tintColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
