//
//  MTSettingsTableViewCell.swift
//  mtrckr
//
//  Created by User on 6/1/17.
//
//

import UIKit

class MTSettingsTableViewCell: MTTableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
