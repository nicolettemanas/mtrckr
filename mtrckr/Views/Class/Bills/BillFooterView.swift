//
//  BillFooterView.swift
//  mtrckr
//
//  Created by User on 11/1/17.
//

import UIKit

class BillFooterView: UITableViewHeaderFooterView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        contentView.backgroundColor = .white
    }
}
